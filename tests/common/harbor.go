package common

import (
	"os/exec"
	"testing"
)

func TestHarbor(t *testing.T) {
	kubeconfig := TestModuleGetStringGlobal(t, KubeConfigPath)

	// HARBOR
	testHarbor := TestModule{
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
	defer testHarbor.TeardownTests()
	testHarbor.RunTests()

	// HARBOR CONFIG
	var harborPortForward *exec.Cmd
	testHarborConfig := TestModule{
		GoTest:       t,
		Name:         "harbor-config",
		TerraformDir: "../testdata/config/harbor",
		Setup: func(tm *TestModule) {
			tm.SetTerraformVar("kube_config_path", kubeconfig)
			tm.SetTerraformVar("toolchain_namespace", tm.GetStringGlobal("namespace"))
			tm.SetTerraformVar("harbor_admin_password", testHarbor.GetTerraformOutput("harbor_admin_password"))
			tm.SetTerraformVar("harbor_hostname", "localhost:8080")
			harborPortForward = exec.Command("kubectl", "port-forward", "-n", "toolchain", "svc/harbor-harbor-core", "8080:80")
			err := harborPortForward.Start()
			if err != nil {
				tm.GoTest.Error(err)
			}
		},
		Tests: func(tm *TestModule) {
		},
		Teardown: func(tm *TestModule) {
			err := harborPortForward.Process.Kill()
			if err != nil {
				tm.GoTest.Error(err)
			}
		},
	}
	defer testHarborConfig.TeardownTests()
	testHarborConfig.RunTests()
}
