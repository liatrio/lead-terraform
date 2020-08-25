package local

import (
	"runtime"
	"testing"

	"github.com/gruntwork-io/terratest/modules/k8s"

	"liatr.io/lead-terraform/tests/common"
)

const Namespace = "namespace"

func TestSetup(t *testing.T) {

	runtime.GOMAXPROCS(2)

	kubeconfig, err := k8s.GetKubeConfigPathE(t)
	if err != nil {
		t.Fatal(err)
	}
	common.TestModuleSetStringGlobal(t, common.KubeConfigPath, kubeconfig)

	// namespaceName = fmt.Sprintf("test-cert-manager-%s", strings.ToLower(random.UniqueId()))

	// options := k8s.NewKubectlOptions("", "", namespaceName)

	// defer k8s.DeleteNamespace(t, options, namespaceName)
	// k8s.CreateNamespace(t, options, namespaceName)

	// SETUP NAMESPACE
	testNamespace := common.TestModule{
		GoTest:       t,
		Name:         "namespace",
		TerraformDir: "../testdata/common/namespace",
		Setup: func(tm *common.TestModule) {
			tm.SetTerraformVar("kube_config_path", kubeconfig)
			// common.NamespaceSetup(tm)
			tm.SetTerraformVar("namespace", "toolchain")
		},
		Tests: func(tm *common.TestModule) {
			tm.SetStringGlobal(Namespace, tm.GetTerraformVar("namespace"))
			common.NamespaceTests(tm)
		},
	}
	defer testNamespace.TeardownTests()
	testNamespace.RunTests()

	// CERT-MANAGER
	testCertManager := common.TestModule{
		GoTest:       t,
		Name:         "cert_manager",
		TerraformDir: "../testdata/tools/cert-manager",
		Setup: func(tm *common.TestModule) {
			tm.SetTerraformVar("namespace", testNamespace.GetTerraformVar("namespace"))
			tm.SetTerraformVar("kube_config_path", kubeconfig)
		},
		Tests:    common.CreateCertManager,
		Teardown: common.DestroyCertManager,
	}
	defer testCertManager.TeardownTests()
	testCertManager.RunTests()

	// TEST CREATE SELF SIGNED ISSUER
	testIssuer := common.TestModule{
		GoTest:       t,
		Name:         "issuer",
		TerraformDir: "../testdata/common/cert-issuer",
		Setup: func(tm *common.TestModule) {
			tm.SetTerraformVar("kube_config_path", kubeconfig)
			tm.SetTerraformVar("namespace", testNamespace.GetTerraformVar("namespace"))
			tm.SetTerraformVar("issuer_kind", "Issuer")
			tm.SetTerraformVar("issuer_name", "test-issuer")
			tm.SetTerraformVar("issuer_type", "selfSigned")
		},
	}
	defer testIssuer.TeardownTests()
	testIssuer.RunTests()

	// Ingress Controller
	testIngressController := common.TestModule{
		GoTest:       t,
		Name:         "ingress",
		TerraformDir: "../testdata/lead/toolchain-ingress",
		Setup: func(tm *common.TestModule) {
			tm.SetTerraformVar("kube_config_path", kubeconfig)

			tm.SetTerraformVar("namespace", testNamespace.GetTerraformVar("namespace"))
			tm.SetTerraformVar("cluster_domain", "tests.lead-terraform.liatr.io")
			tm.SetTerraformVar("issuer_kind", "Issuer")
			tm.SetTerraformVar("issuer_name", "test-issuer")
			tm.SetTerraformVar("crd_waiter", "NA")
			tm.SetTerraformVar("ingress_controller_type", "ClusterIP")
		},
	}
	defer testIngressController.TeardownTests()
	testIngressController.RunTests()

	// RUN SUB TESTS
	t.Run("Modules", testModules)
}

func testModules(t *testing.T) {
	//t.Run("Dashboard", testLeadDashboard)
	//t.Run("SDM", testLeadSdm)
	//t.Run("KubeResourceReport", common.KubeResourceReportTest)
	//t.Run("ExternalDNS", common.ExternalDnsTest)
	//t.Run("KubeDownscaler", common.KubeDownscalerTest)
	//t.Run("K8sSpotTerminationHandler", common.K8sSpotTerminationHandlerTest)
	//t.Run("KubeJanitor", common.KubeJanitorTest)
	//t.Run("MetricsServer", common.MetricsServerTest)
	t.Run("SonarQube", common.SonarQubeTest);
}

func testLeadDashboard(t *testing.T) {
	t.Parallel()

	kubeconfig := common.TestModuleGetStringGlobal(t, common.KubeConfigPath)

	// LEAD DASHBOARD NAMESPACE
	// testNamespace := common.TestModule{
	// 	GoTest: t,
	// 	Name: "lead_dashboard_namespace",
	// 	TerraformDir: tempNamespaceModule,
	// 	Setup: func(tm *common.TestModule) {
	// 		tm.SetTerraformVar("kube_config_path", kubeconfig)
	// 		common.NamespaceSetup(tm)
	// 	},
	// 	Tests: common.NamespaceTests,
	// }
	// defer testNamespace.TeardownTests()
	// testNamespace.RunTests()

	// LEAD DASHBOARD
	testDashboard := common.TestModule{
		GoTest:       t,
		Name:         "lead_dashboard",
		TerraformDir: "../testdata/lead/dashboard",
		Setup: func(tm *common.TestModule) {
			tm.SetTerraformVar("kube_config_path", kubeconfig)
			tm.SetTerraformVar("namespace", tm.GetStringGlobal(Namespace))
			tm.SetTerraformVar("root_zone_name", "local")
			tm.SetTerraformVar("cluster_id", "docker-for-desktop")
			tm.SetTerraformVar("cluster_domain", "local")
			tm.SetTerraformVar("dashboard_version", common.DashboardVersion)
			tm.SetTerraformVar("k8s_storage_class", "hostpath")
			tm.SetTerraformVar("local", "true")
		},
	}
	defer testDashboard.TeardownTests()
	testDashboard.RunTests()
}

func testLeadSdm(t *testing.T) {
	t.Parallel()

	kubeconfig := common.TestModuleGetStringGlobal(t, common.KubeConfigPath)

	// LEAD SDM NAMESPACE
	// testNamespace := common.TestModule{
	// 	GoTest: t,
	// 	Name: "sdm_namespace",
	// 	TerraformDir: "../testdata/common/namespace",
	// 	Setup: func(tm *common.TestModule) {
	// 		tm.SetTerraformVar("kube_config_path", kubeconfig)
	// 		tm.SetTerraformVar("namespace", "toolchain")
	// 		// common.NamespaceSetup(tm)
	// 	},
	// 	Tests: common.NamespaceTests,
	// }
	// defer testNamespace.TeardownTests()
	// testNamespace.RunTests()

	// LEAD SDM
	// tiller_service_account := common.TestModuleGetStringGlobal(t, "tiller_service_account")
	testSdm := common.TestModule{
		GoTest:       t,
		Name:         "sdm",
		TerraformDir: "../testdata/tools/sdm",
		Setup: func(tm *common.TestModule) {
			tm.SetTerraformVar("kube_config_path", kubeconfig)

			tm.SetTerraformVar("namespace", tm.GetStringGlobal(Namespace))
			tm.SetTerraformVar("system_namespace", tm.GetStringGlobal(Namespace))
			tm.SetTerraformVar("sdm_version", common.LeadSdmVersion)
			tm.SetTerraformVar("product_version", common.ProductVersion)
			tm.SetTerraformVar("cluster_id", "docker-desktop")
			tm.SetTerraformVar("slack_bot_token", "xoxb-1111111111-111111111111-aaaaaaaaaaaaaaaaaaaaaaaa")
			tm.SetTerraformVar("slack_client_signing_secret", "11111111111111111111111111111111")
			tm.SetTerraformVar("root_zone_name", "lead-terraform.test.liatr.io")
		},
	}
	defer testSdm.TeardownTests()
	testSdm.RunTests()

}
