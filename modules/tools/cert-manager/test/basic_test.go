package test

import (
	"path"
	"testing"

	"github.com/gruntwork-io/terratest/modules/files"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/terraform"

	"github.com/stretchr/testify/assert"
)

// An example of how to test the simple Terraform module in examples/terraform-basic-example using Terratest.
func TestTerraformBasicExample(t *testing.T) {
	t.Parallel()

	expectedNamespace := "test"
	expectedStatus := "deployed"

	kubectlOptions := k8s.NewKubectlOptions("", "", "default")
	k8s.CreateNamespace(t, kubectlOptions, expectedNamespace)
	defer k8s.DeleteNamespace(t, kubectlOptions, expectedNamespace)

	tfdir, err := files.CopyTerraformFolderToTemp("../", "tf-cert-manager-")
	if err != nil {
		t.Fatal(err)
	}

	files.CopyFolderContents(path.Join(".", "fixtures"), tfdir)

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// website::tag::1::Set the path to the Terraform code that will be tested.
		// The path to where our Terraform code is located
		TerraformDir: tfdir,

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"namespace": expectedNamespace,
			"cert_manager_service_account_role_arn": "",
		},

		// Disable colors in Terraform commands so its easier to parse stdout/stderr
		NoColor: true,
	})

	// website::tag::4::Clean up resources with "terraform destroy". Using "defer" runs the command at the end of the test, whether the test succeeds or fails.
	// At the end of the test, run `terraform destroy` to clean up any resources that were created

	// website::tag::2::Run "terraform init" and "terraform apply".
	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)
	defer terraform.Destroy(t, terraformOptions)



	actualNamespace := terraform.Output(t, terraformOptions, "namespace")
	actualStatus := terraform.Output(t, terraformOptions, "status")


	assert.Equal(t, expectedNamespace, actualNamespace)
	assert.Equal(t, expectedStatus, actualStatus)




}
