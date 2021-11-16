package common

import (
	"testing"
)

func TestKeycloak(t *testing.T) {
	t.Parallel()
	kubeconfig := TestModuleGetStringGlobal(t, KubeConfigPath)

	// LEAD KEYCLOAK
	testKeycloak := TestModule{
		GoTest:       t,
		Name:         "keycloak",
		TerraformDir: "../testdata/tools/keycloak",
		Setup: func(tm *TestModule) {
			tm.SetTerraformVar("kube_config_path", kubeconfig)
			tm.SetTerraformVar("namespace", tm.GetStringGlobal("namespace"))
			tm.SetTerraformVar("cluster", "docker-for-desktop")
			tm.SetTerraformVar("root_zone_name", "local")
			tm.SetTerraformVar("postgres_password", "xxxxxx")
			tm.SetTerraformVar("keycloak_admin_password", "xxxxxx")
		},
	}
	defer testKeycloak.TeardownTests()
	testKeycloak.RunTests()
}
