package common

import (
	"testing"
)

func ExternalDnsTest(t *testing.T) {
	t.Parallel()

	kubeconfig := TestModuleGetStringGlobal(t, KubeConfigPath)

	testExternalDns := TestModule{
		GoTest:       t,
		Name:         "external_dns",
		TerraformDir: "../testdata/tools/external-dns",
		Setup: func(tm *TestModule) {
			tm.SetTerraformVar("kube_config_path", kubeconfig)
			tm.SetTerraformVar("namespace", tm.GetStringGlobal("namespace"))
			tm.SetTerraformVar("domain_filter", "test.com")
		},
	}
	defer testExternalDns.TeardownTests()
	testExternalDns.RunTests()
}
