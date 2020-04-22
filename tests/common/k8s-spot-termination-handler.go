package common

import (
	"testing"
)

func K8sSpotTerminationHandlerTest(t *testing.T) {
	t.Parallel()

	kubeconfig := TestModuleGetStringGlobal(t, KubeConfigPath)

	testK8sSpotTerminationHandler := TestModule{
		GoTest:       t,
		Name:         "k8s_spot_termination_handler",
		TerraformDir: "../testdata/tools/k8s-spot-termination-handler",
		Setup: func(tm *TestModule) {
			tm.SetTerraformVar("kube_config_path", kubeconfig)
			tm.SetTerraformVar("namespace", tm.GetStringGlobal("namespace"))
		},
	}
	defer testK8sSpotTerminationHandler.TeardownTests()
	testK8sSpotTerminationHandler.RunTests()
}
