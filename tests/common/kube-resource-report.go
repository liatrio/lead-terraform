package common

import(
	"testing"
)

func KubeResourceReportTest(t *testing.T) {
	t.Parallel()

	kubeconfig:= TestModuleGetStringGlobal(t, KubeConfigPath)

	testDashboard := TestModule{
		GoTest: t,
		Name: "kube_resource_report",
		TerraformDir: "../testdata/tools/kube-resource-report",
		Setup: func(tm *TestModule) {
			tm.SetTerraformVar("kube_config_path", kubeconfig)
			tm.SetTerraformVar("namespace", tm.GetStringGlobal("namespace"))
			tm.SetTerraformVar("root_zone_name", "local")
			tm.SetTerraformVar("cluster", "docker-for-desktop")
		},
	}
	defer testDashboard.TeardownTests()
	testDashboard.RunTests()

}