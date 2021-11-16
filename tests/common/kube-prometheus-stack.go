package common

import (
	"testing"
)

func TestKubePrometheusStack(t *testing.T) {
	t.Parallel()
	kubeconfig := TestModuleGetStringGlobal(t, KubeConfigPath)

	testKubePrometheusStack := TestModule{
		GoTest:       t,
		Name:         "kube_prometheus_stack",
		TerraformDir: "../testdata/tools/kube-prometheus-stack",
		Setup: func(tm *TestModule) {
			tm.SetTerraformVar("kube_config_path", kubeconfig)
			tm.SetTerraformVar("namespace", tm.GetStringGlobal("namespace"))
			tm.SetTerraformVar("grafana_hostname", "grafana.toolchain.lead-terraform.liatr.io")
			tm.SetTerraformVar("prometheus_slack_webhook_url", "https://fake.slack.io")
			tm.SetTerraformVar("prometheus_slack_channel", "fake_channel")
		},
	}
	defer testKubePrometheusStack.TeardownTests()
	testKubePrometheusStack.RunTests()
}
