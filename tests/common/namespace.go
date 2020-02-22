package common

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/random"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	authv1 "k8s.io/api/authorization/v1"
)

func CreateNamespace(t *testing.T, terraformOptions *terraform.Options, kubeConfigPath string) {
	expectedNamespace := fmt.Sprintf("test-%s", strings.ToLower(random.UniqueId()))
	terraformOptions.Vars["namespace"] = expectedNamespace

	terraform.InitAndApply(t, terraformOptions)

	k8sOptions := k8s.NewKubectlOptions("", kubeConfigPath, expectedNamespace)

	actualNamespace := terraform.Output(t, terraformOptions, "name")
	actualTillerServiceAccountName := terraform.Output(t, terraformOptions, "tiller_service_account")

	assert.Equal(t, expectedNamespace, actualNamespace)
	assert.Equal(t, "tiller", actualTillerServiceAccountName)

	token := k8s.GetServiceAccountAuthToken(t, k8sOptions, actualTillerServiceAccountName)

	require.NoError(t, k8s.AddConfigContextForServiceAccountE(
		t,
		k8sOptions,
		actualTillerServiceAccountName, // for this test we will name the context after the ServiceAccount
		actualTillerServiceAccountName,
		token,
	))

	tillerContextK8sOptions := k8s.NewKubectlOptions(actualTillerServiceAccountName, kubeConfigPath, expectedNamespace)

	adminListPodAction := authv1.ResourceAttributes{
		Namespace: "kube-system",
		Verb:      "list",
		Resource:  "pod",
	}
	require.False(t, k8s.CanIDo(t, tillerContextK8sOptions, adminListPodAction))

	namespaceListPodAction := authv1.ResourceAttributes{
		Namespace: expectedNamespace,
		Verb:      "list",
		Resource:  "pod",
	}
	require.True(t, k8s.CanIDo(t, tillerContextK8sOptions, namespaceListPodAction))
}

func DestroyNamespace(t *testing.T, terraformOptions *terraform.Options) {
	terraform.Destroy(t, terraformOptions)
}