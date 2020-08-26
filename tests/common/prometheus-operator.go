package common

import (
	"testing"
)

func TestPrometheusOperator(t *testing.T) {
	t.Parallel()
	kubeconfig := TestModuleGetStringGlobal(t, KubeConfigPath)

	// LEAD HARBOR
	testDashboard := TestModule{
		GoTest:       t,
		Name:         "harbor",
		TerraformDir: "../testdata/tools/prometheus-operator",
		Setup: func(tm *TestModule) {
			tm.SetTerraformVar("kube_config_path", kubeconfig)
			tm.SetTerraformVar("namespace", tm.GetStringGlobal("namespace"))
			tm.SetTerraformVar("grafana_hostname", "grafana.toolchain.lead-terraform.liatr.io")
			tm.SetTerraformVar("prometheus_slack_webhook_url", "https://fake.slack.io")
			tm.SetTerraformVar("prometheus_slack_channel", "fake_channel")
		},
	}
	defer testDashboard.TeardownTests()
	testDashboard.RunTests()
}
