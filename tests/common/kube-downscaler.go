package common

import (
	"testing"
)

func KubeDownscalerTest(t *testing.T) {
	t.Parallel()

	kubeconfig := TestModuleGetStringGlobal(t, KubeConfigPath)

	testKubeDownscaler := TestModule{
		GoTest:       t,
		Name:         "kube_downscaler",
		TerraformDir: "../testdata/tools/kube-downscaler",
		Setup: func(tm *TestModule) {
			tm.SetTerraformVar("kube_config_path", kubeconfig)
			tm.SetTerraformVar("namespace", tm.GetStringGlobal("namespace"))
			tm.SetTerraformVar("uptime", "Mon-Fri 05:00-19:00 America/Los_Angeles")
		},
	}
	defer testKubeDownscaler.TeardownTests()
	testKubeDownscaler.RunTests()
}
