package local

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/k8s"

	"liatr.io/lead-terraform/tests/common"
)

func TestTerraformForNamespace(t *testing.T) {
	t.Parallel()
	
	kubeconfig, err := k8s.GetKubeConfigPathE(t)
	if err != nil {
		t.Fatal(err)
	}

	testNamespace := common.TestModule{
		GoTest: t,
		Name: "namespace",
		TerraformDir: "../testdata/common/namespace",
		Setup: func(tm *common.TestModule) {
			tm.SetTerraformVar("kube_config_path", kubeconfig)
			common.NamespaceSetup(tm)
		},
		Tests: common.NamespaceTests,
	}
	defer testNamespace.TeardownTests()
	testNamespace.RunTests()
}
