package common

import (
	"testing"
)

func KubeJanitorTest(t *testing.T) {
	t.Parallel()

	kubeconfig := TestModuleGetStringGlobal(t, KubeConfigPath)

	testKubeJanitor := TestModule{
		GoTest:       t,
		Name:         "kube_janitor",
		TerraformDir: "../testdata/tools/kube-janitor",
		Setup: func(tm *TestModule) {
			tm.SetTerraformVar("kube_config_path", kubeconfig)
			tm.SetTerraformVar("namespace", tm.GetStringGlobal("namespace"))
		},
	}
	defer testKubeJanitor.TeardownTests()
	testKubeJanitor.RunTests()
}
