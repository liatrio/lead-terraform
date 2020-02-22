package aws

import (
	"fmt"
	// "os"
	// "os/exec"
	"flag"
	"strings"

	"liatr.io/lead-terraform/tests/common"

	"testing"
	// "github.com/stretchr/testify/require"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/random"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	// "github.com/gruntwork-io/terratest/modules/k8s"
)

var flagNoColor bool

func init()  {
	flag.BoolVar(&flagNoColor, "noColor", false, "Disable color in log output")
}

const testPathEks = "../testdata/aws/eks"
const testPathNamespace = "../testdata/aws/namespace"
const testPathEksAuth = "../testdata/aws/eks-auth"

func TestEksCluster(t *testing.T) {
	// kubeConfigPath := k8s.CopyHomeKubeConfigToTemp(t)
	// defer os.Remove(kubeConfigPath)
	kubeConfigPath := testPathEksAuth + "/kubeconfig"

	defer test_structure.RunTestStage(t, "destroy_eks_cluster", func() {
		destroyEksCluster(t)
	})

	test_structure.RunTestStage(t, "create_eks_cluster", func() {
		createEksCluster(t)
	})

	defer test_structure.RunTestStage(t, "destroy_eks_cluster_config", func() {
		destroyEksClusterConfig(t)
	})

	test_structure.RunTestStage(t, "create_eks_cluster_config", func() {
		createEksClusterConfig(t)
	})

	defer test_structure.RunTestStage(t, "destroy_namespace", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testPathNamespace)
		common.DestroyNamespace(t, terraformOptions)
		test_structure.CleanupTestDataFolder(t, testPathNamespace)
	})

	test_structure.RunTestStage(t, "create_namespace", func() {
		clusterID := test_structure.LoadString(t, testPathEks, "cluster_id")
		terraformOptions := &terraform.Options{
			TerraformDir: testPathNamespace,
			Vars: map[string]interface{}{
				"cluster_id": clusterID,
			},
			NoColor: true,
		}
		common.CreateNamespace(t, terraformOptions, kubeConfigPath)
		test_structure.SaveTerraformOptions(t, testPathNamespace, terraformOptions)
	})
}

func createEksCluster(t *testing.T) {
	clusterName := fmt.Sprintf("test-%s", strings.ToLower(random.UniqueId()))
	terraformOptions := &terraform.Options{
		TerraformDir: testPathEks,
		Vars: map[string]interface{}{
			"cluster": clusterName,
			"region": "us-east-1",
		},
		NoColor: flagNoColor,
	}
	terraform.InitAndApply(t, terraformOptions)
	test_structure.SaveString(t, testPathEks, "cluster_id", terraform.Output(t, terraformOptions, "cluster_id"))
	test_structure.SaveTerraformOptions(t, testPathEks, terraformOptions)
}

func destroyEksCluster(t *testing.T) {
	terraformOptions := test_structure.LoadTerraformOptions(t, testPathEks)
	terraform.Destroy(t, terraformOptions)
	test_structure.CleanupTestDataFolder(t, testPathEks)
}

func createEksClusterConfig(t *testing.T) {
	clusterName := test_structure.LoadString(t, testPathEks, "cluster_id")
	terraformOptions := &terraform.Options{
		TerraformDir: testPathEksAuth,
		Vars: map[string]interface{}{
			"cluster_name": clusterName,
			"kubeconfig_path": "./",
		},
		NoColor: flagNoColor,
	}
	terraform.InitAndApply(t, terraformOptions)
	test_structure.SaveTerraformOptions(t, testPathEksAuth, terraformOptions)
	test_structure.SaveString(t, testPathEksAuth, "kubeConfigPath", terraform.Output(t, terraformOptions, "kube_config_path"))
}

func destroyEksClusterConfig(t *testing.T) {
	terraformOptions := test_structure.LoadTerraformOptions(t, testPathEksAuth)
	terraform.Destroy(t, terraformOptions)
	test_structure.CleanupTestDataFolder(t, testPathEksAuth)
}