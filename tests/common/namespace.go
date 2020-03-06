package common

import (
	"github.com/gruntwork-io/terratest/modules/k8s"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	authv1 "k8s.io/api/authorization/v1"
)

func NamespaceSetup(tm *TestModule) {
	// expectedNamespace := fmt.Sprintf("test-%s", strings.ToLower(random.UniqueId()))
	tm.SetTerraformVar("namespace", "toolchain")
}

func NamespaceTests(tm *TestModule) {
	expectedNamespace := tm.GetTerraformVar("namespace")
	kubeConfigPath := tm.GetStringGlobal(KubeConfigPath)
	k8sOptions := k8s.NewKubectlOptions("", kubeConfigPath, expectedNamespace)

	actualNamespace := tm.GetTerraformOutput("name")
	actualTillerServiceAccountName := tm.GetTerraformOutput("tiller_service_account")

	assert.Equal(tm.GoTest, expectedNamespace, actualNamespace)
	assert.Equal(tm.GoTest, "tiller", actualTillerServiceAccountName)

	token := k8s.GetServiceAccountAuthToken(tm.GoTest, k8sOptions, actualTillerServiceAccountName)

	require.NoError(tm.GoTest, k8s.AddConfigContextForServiceAccountE(
		tm.GoTest,
		k8sOptions,
		actualTillerServiceAccountName, // for this test we will name the context after the ServiceAccount
		actualTillerServiceAccountName,
		token,
	))

	tillerContextK8sOptions := k8s.NewKubectlOptions(actualTillerServiceAccountName, kubeConfigPath, expectedNamespace)

	namespaceListPodAction := authv1.ResourceAttributes{
		Namespace: expectedNamespace,
		Verb:      "list",
		Resource:  "pod",
	}
	require.True(tm.GoTest, k8s.CanIDo(tm.GoTest, tillerContextK8sOptions, namespaceListPodAction))

	require.True(tm.GoTest, k8s.CanIDo(
		tm.GoTest,
		tillerContextK8sOptions, 
		authv1.ResourceAttributes{
			Namespace: expectedNamespace,
			Verb:		"get",
			Resource: "builds",
		},
	))
}