package test

import (
	"fmt"
	"path"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/files"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/random"

	"github.com/stretchr/testify/assert"
)

func TestCertManager_Basic(t *testing.T) {
	t.Parallel()

	expectedNamespace := fmt.Sprintf("terratest-%s", strings.ToLower(random.UniqueId()))
	expectedStatus := "deployed"

	kubectlOptions := k8s.NewKubectlOptions("", "", "")
	k8s.CreateNamespace(t, kubectlOptions, expectedNamespace)
	defer k8s.DeleteNamespace(t, kubectlOptions, expectedNamespace)

	tfdir, err := files.CopyTerraformFolderToTemp("../", "tf-cert-manager-")
	if err != nil {
		t.Errorf("error copying module to tmpdir: %s", err)
	}

	if err = files.CopyFolderContents(path.Join(".", "fixtures"), tfdir); err != nil {
		t.Errorf("error copying fixtures to tmpdir: %s", err)
	}

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: tfdir,
		Vars: map[string]interface{}{
			"namespace": expectedNamespace,
			"cert_manager_service_account_role_arn": "",
		},
		NoColor: true,
	})

	terraform.InitAndApply(t, terraformOptions)
	defer terraform.Destroy(t, terraformOptions)

	actualNamespace := terraform.Output(t, terraformOptions, "namespace")
	actualStatus := terraform.Output(t, terraformOptions, "status")

	assert.Equal(t, expectedNamespace, actualNamespace)
	assert.Equal(t, expectedStatus, actualStatus)
}
