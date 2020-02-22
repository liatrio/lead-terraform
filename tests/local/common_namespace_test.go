package local

import (
	"os"
	"testing"
	"liatr.io/lead-terraform/tests/common"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/k8s"
)

func TestTerraformForNamespace(t *testing.T) {
	t.Parallel()
	
	kubeConfigPath := k8s.CopyHomeKubeConfigToTemp(t)
	defer os.Remove(kubeConfigPath)

	terraformOptions := &terraform.Options{
		TerraformDir: "../../modules/common/namespace",
		Vars: map[string]interface{}{
			// "namespace": expectedNamespace,
		},
		NoColor: true,
	}

	defer common.DestroyNamespace(t, terraformOptions)
	common.CreateNamespace(t, terraformOptions, kubeConfigPath)
}
