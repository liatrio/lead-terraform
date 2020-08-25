package common

import(
	"testing"
)

func TestHarbor(t *testing.T) {
	t.Parallel()
	kubeconfig := TestModuleGetStringGlobal(t, KubeConfigPath)

	// LEAD HARBOR
	testDashboard := TestModule{
		GoTest:       t,
		Name:         "harbor",
		TerraformDir: "../testdata/tools/harbor",
		Setup: func(tm *TestModule) {
			tm.SetTerraformVar("kube_config_path", kubeconfig)
			tm.SetTerraformVar("toolchain_namespace", tm.GetStringGlobal("namespace"))
			tm.SetTerraformVar("root_zone_name", "local")
			tm.SetTerraformVar("cluster", "docker-for-desktop")
			tm.SetTerraformVar("k8s_storage_class", "hostpath")
			tm.SetTerraformVar("issuer_kind", "Issuer")
			tm.SetTerraformVar("issuer_name", "test-issuer")
		},
	}
	defer testDashboard.TeardownTests()
	testDashboard.RunTests()
}