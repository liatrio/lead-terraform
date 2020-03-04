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
	assumeIamRole, _ := os.LookupEnv("TERRATEST_IAM_ROLE")
	// CLUSTER 
	testCluster := common.TestModule{
		GoTest: t,
		Name: "eks_cluster",
		TerraformDir: "../testdata/aws/eks",
		Setup: func(tm *common.TestModule) {
			clusterName := fmt.Sprintf("test-%s", strings.ToLower(random.UniqueId()))
			tm.SetTerraformVar("cluster", clusterName)
			tm.SetTerraformVar("region", "us-east-1")
			tm.SetTerraformVar("aws_assume_role_arn", assumeIamRole)
		},
		Tests: func(tm *common.TestModule) {
			tm.SetStringGlobal(common.KubeConfigPath, tm.GetTerraformOutput("kubeconfig"))
		},
	}
	defer testCluster.TeardownTests()
	testCluster.RunTests()

	// NAMESPACE
	testNamespace := common.TestModule{
		GoTest: t,
		Name: "namespace",
		TerraformDir: "../testdata/common/namespace",
		Setup: func(tm *common.TestModule) {
			tm.SetTerraformVar("kube_config_path", testCluster.GetTerraformOutput("kubeconfig"))
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
			tm.SetTerraformVar("kube_config_path", testCluster.GetTerraformOutput("kubeconfig"))
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
			tm.SetTerraformVar("kube_config_path", testCluster.GetTerraformOutput("kubeconfig"))
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
			tm.SetTerraformVar("kube_config_path", testCluster.GetTerraformOutput("kubeconfig"))

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
