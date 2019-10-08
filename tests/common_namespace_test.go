package test

import (
	"os"
	"testing"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	authv1 "k8s.io/api/authorization/v1"
	"github.com/stretchr/testify/require"

	"github.com/gruntwork-io/terratest/modules/k8s"
)

// An example of how to test the simple Terraform module in examples/terraform-basic-example using Terratest.
func TestTerraformForNamespace(t *testing.T) {
	t.Parallel()

	expectedNamespace := "terratest-test-namespace"
	expectedTillerServiceAccountName := "tiller"

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../modules/common/namespace",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"namespace": expectedNamespace,

		},

		//// Variables to pass to our Terraform code using -var-file options
		//VarFiles: []string{"varfile.tfvars"},

		// Disable colors in Terraform commands so its easier to parse stdout/stderr
		NoColor: true,
	}

	// Setup the kubectl config and context. Here we choose to create a new one because we will be manipulating the
	// entries to be able to add a new authentication option.
	tmpConfigPath := k8s.CopyHomeKubeConfigToTemp(t)
	defer os.Remove(tmpConfigPath)
	options := k8s.NewKubectlOptions("", tmpConfigPath)


	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	options.Namespace = expectedNamespace
	token := k8s.GetServiceAccountAuthToken(t, options, expectedTillerServiceAccountName)

	require.NoError(t, k8s.AddConfigContextForServiceAccountE(
		t,
		options,
		expectedTillerServiceAccountName, // for this test we will name the context after the ServiceAccount
		expectedTillerServiceAccountName,
		token,
	))

	serviceAccountKubectlOptions := k8s.NewKubectlOptions(expectedTillerServiceAccountName, tmpConfigPath)

	// Run `terraform output` to get the values of output variables
	actualNamespace := terraform.Output(t, terraformOptions, "name")
	actualTillerServiceAccountName := terraform.Output(t, terraformOptions, "tiller_service_account")

	// Verify we're getting back the outputs we expect
	assert.Equal(t, expectedNamespace, actualNamespace)
	assert.Equal(t, expectedTillerServiceAccountName, actualTillerServiceAccountName)


	// At this point all requests made with serviceAccountKubectlOptions will be auth'd as that ServiceAccount. So let's
	// verify that! We will check:
	// - we can't access the kube-system namespace
	adminListPodAction := authv1.ResourceAttributes{
		Namespace: "kube-system",
		Verb:      "list",
		Resource:  "pod",
	}
	require.True(t, k8s.CanIDo(t, serviceAccountKubectlOptions, adminListPodAction))
	// - we can access the namespace the service account is in
	namespaceListPodAction := authv1.ResourceAttributes{
		Namespace: expectedNamespace,
		Verb:      "list",
		Resource:  "pod",
	}
	require.True(t, k8s.CanIDo(t, serviceAccountKubectlOptions, namespaceListPodAction))
}

