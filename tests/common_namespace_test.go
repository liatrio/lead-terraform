package test

import (
	"testing"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"

)

// An example of how to test the simple Terraform module in examples/terraform-basic-example using Terratest.
func TestTerraformForNamespace(t *testing.T) {
	t.Parallel()

	expectedNamespace := "howdynamespace"
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

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the values of output variables
	actualNamespace := terraform.Output(t, terraformOptions, "name")
	actualTillerServiceAccountName := terraform.Output(t, terraformOptions, "tiller_service_account")

	// Verify we're getting back the outputs we expect
	assert.Equal(t, expectedNamespace, actualNamespace)
	assert.Equal(t, expectedTillerServiceAccountName, actualTillerServiceAccountName)
}

