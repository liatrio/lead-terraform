package aws

import (
	"fmt"
	"os"
	"flag"
	"strings"

	"liatr.io/lead-terraform/tests/common"

	"testing"
	"github.com/gruntwork-io/terratest/modules/random"
)

var flagNoColor bool

func init()  {
	flag.BoolVar(&flagNoColor, "noColor", false, "Disable color in log output")
}

func TestEksCluster(t *testing.T) {
	// CLUSTER 
	testCluster := common.TestModule{
		GoTest: t,
		Name: "eks_cluster",
		TerraformDir: "../testdata/aws/eks",
		Setup: func(tm *common.TestModule) {
			clusterName := fmt.Sprintf("test-%s", strings.ToLower(random.UniqueId()))
			tm.SetTerraformVar("cluster", clusterName)
			tm.SetTerraformVar("region", "us-east-1")
		},
	}
	defer testCluster.TeardownTests()
	testCluster.RunTests()

	// CLUSTER CONFIG
	testClusterConfig := common.TestModule{
		GoTest: t,
		Name: "cluster_config",
		TerraformDir: "../testdata/aws/eks-auth",
		Setup: func(tm *common.TestModule) {
			workingDirectory, err := os.Getwd()
			if err != nil {
				t.Fatalf("Failed to get working directory: %s", err)
			}
			tm.SetTerraformVar("cluster_name", testCluster.GetTerraformVar("cluster"))
			tm.SetTerraformVar("kubeconfig_path", workingDirectory)
			tm.SetTerraformVar("region", "us-east-1")
		},
		Tests: createEksClusterConfig,
	}
	defer testClusterConfig.TeardownTests()
	testClusterConfig.RunTests()

	// NAMESPACE
	testNamespace := common.TestModule{
		GoTest: t,
		Name: "namespace",
		TerraformDir: "../testdata/common/namespace",
		Setup: func(tm *common.TestModule) {
			tm.SetTerraformVar("kube_config_path", testClusterConfig.GetTerraformOutput("kube_config_path"))
			common.NamespaceSetup(tm)
		},
		Tests: common.NamespaceTests,
	}
	defer testNamespace.TeardownTests()
	testNamespace.RunTests()

	// CERT-MANAGER
	testCertManager := common.TestModule{
		GoTest: t,
		Name: "cert_manager",
		TerraformDir: "../testdata/tools/cert-manager",
		Setup: func(tm *common.TestModule) {
			tm.SetTerraformVar("namespace", testNamespace.GetTerraformVar("namespace"))
			tm.SetTerraformVar("tiller_cluster_role_binding", "NA")
			tm.SetTerraformVar("tiller_service_account", testNamespace.GetTerraformOutput("tiller_service_account"))
			tm.SetTerraformVar("kube_config_path", testClusterConfig.GetTerraformOutput("kube_config_path"))
		},
		Tests: common.CreateCertManager,
		Teardown: common.DestroyCertManager,
	}
	defer testCertManager.TeardownTests()
	testCertManager.RunTests()

	// Ingress Controller
	testIngressController := common.TestModule{
		GoTest: t,
		Name: "ingress",
		TerraformDir: "../testdata/lead/toolchain-ingress",
		Setup: func(tm *common.TestModule) {
			tm.SetTerraformVar("kube_config_path", testClusterConfig.GetTerraformOutput("kube_config_path"))
			tm.SetTerraformVar("tiller_service_account", testNamespace.GetTerraformOutput("tiller_service_account"))
		
			tm.SetTerraformVar("namespace", testNamespace.GetTerraformVar("namespace"))
			tm.SetTerraformVar("cluster_domain", "tests.lead-terraform.liatr.io")
			tm.SetTerraformVar("issuer_kind", "ClusterIssuer")
			tm.SetTerraformVar("issuer_name", "testIssuer")
			tm.SetTerraformVar("crd_waiter", "NA")
		},
	}
	defer testIngressController.TeardownTests()
	testIngressController.RunTests()

	// SDM
	testSdm := common.TestModule{
		GoTest: t,
		Name: "sdm",
		TerraformDir: "../testdata/tools/sdm",
		Setup: func(tm *common.TestModule) {
			tm.SetTerraformVar("tiller_service_account", testNamespace.GetTerraformOutput("tiller_service_account"))
			tm.SetTerraformVar("kube_config_path", testClusterConfig.GetTerraformOutput("kube_config_path"))

			tm.SetTerraformVar("product_stack", "aws")
			tm.SetTerraformVar("namespace", testNamespace.GetTerraformVar("namespace"))
			tm.SetTerraformVar("system_namespace", testNamespace.GetTerraformVar("namespace"))
			tm.SetTerraformVar("sdm_version", "2.0.3")
			tm.SetTerraformVar("product_version", "2.0.0")
			tm.SetTerraformVar("cluster_id", testCluster.GetTerraformVar("cluster"))
			tm.SetTerraformVar("slack_bot_token", "xoxb-1111111111-111111111111-aaaaaaaaaaaaaaaaaaaaaaaa")
			tm.SetTerraformVar("slack_client_signing_secret", "11111111111111111111111111111111")
			tm.SetTerraformVar("root_zone_name", "lead-terraform.test.liatr.io")
		},
	}
	defer testSdm.TeardownTests()
	testSdm.RunTests()
}

func createEksClusterConfig(tm *common.TestModule) {
	// tm.SetString("clusterEndpoint", tm.GetTerraformOutput("cluster_endpoint"))
	// tm.SetString("clusterCertificateAuthorityData", tm.GetTerraformOutput("cluster_certificate_authority_data"))
	// tm.SetString("clusterToken", tm.GetTerraformOutput("cluster_token"))
	tm.SetStringGlobal(common.KubeConfigPath, tm.GetTerraformOutput("kube_config_path"))
}