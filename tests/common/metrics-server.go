package common

import (
	"testing"
)

func MetricsServerTest(t *testing.T) {
	t.Parallel()

	kubeconfig := TestModuleGetStringGlobal(t, KubeConfigPath)

	testMetricsServer := TestModule{
		GoTest:       t,
		Name:         "metrics_server",
		TerraformDir: "../testdata/tools/metrics-server",
		Setup: func(tm *TestModule) {
			tm.SetTerraformVar("kube_config_path", kubeconfig)
			tm.SetTerraformVar("namespace", tm.GetStringGlobal("namespace"))
		},
	}
	defer testMetricsServer.TeardownTests()
	testMetricsServer.RunTests()
}
