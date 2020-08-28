package common

import(
	"testing"
)

func SonarQubeTest(t *testing.T) {
	t.Parallel()
	kubeconfig := TestModuleGetStringGlobal(t, KubeConfigPath)


	// LEAD SONARQUBE
	testSonarQube := TestModule{
		GoTest:       t,
		Name:         "sonarqube",
		TerraformDir: "../testdata/tools/sonarqube",
		Setup: func(tm *TestModule) {
			tm.SetTerraformVar("kube_config_path", kubeconfig)
			tm.SetTerraformVar("namespace", tm.GetStringGlobal("namespace"))
			tm.SetTerraformVar("enable_sonarqube", "true");
		},
	}
	defer testSonarQube.TeardownTests()
	testSonarQube.RunTests()
} 
