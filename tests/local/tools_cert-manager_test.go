package local

import (
	"fmt"
	"strings"

	"liatr.io/lead-terraform/tests/common"

	"testing"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/k8s"
)

func TestCertManager(t *testing.T) {
	t.Parallel()
	
	kubeconfig, err := k8s.GetKubeConfigPathE(t)
	if err != nil {
		t.Fatal(err)
	}
	common.TestModuleSetStringGlobal(t, common.KubeConfigPath, kubeconfig)

	namespaceName := fmt.Sprintf("test-cert-manager-%s", strings.ToLower(random.UniqueId()))

	options := k8s.NewKubectlOptions("", "", namespaceName)

	defer k8s.DeleteNamespace(t, options, namespaceName)
	k8s.CreateNamespace(t, options, namespaceName)

	// TEST CREATE CERT-MANAGER
	testCertManager := common.TestModule{
		GoTest: t,
		Name: "cert_manager",
		TerraformDir: "../testdata/tools/cert-manager",
		Setup: func(tm *common.TestModule) {
			tm.SetTerraformVar("namespace", namespaceName)
			tm.SetTerraformVar("tiller_cluster_role_binding", "NA")
			tm.SetTerraformVar("tiller_service_account", "")
			// tm.SetTerraformVar("tiller_service_account", testNamespace.GetTerraformOutput("tiller_service_account"))
			tm.SetTerraformVar("kube_config_path", kubeconfig)
		},
		Tests: common.CreateCertManager,
		Teardown: common.DestroyCertManager,
	}
	defer testCertManager.TeardownTests()
	testCertManager.RunTests()

	// TEST CREATE SELF SIGNED ISSUER
	selfSignedIssuerTerraformOptions := &terraform.Options{
		TerraformDir: "../../modules/common/cert-issuer",
		Vars: map[string]interface{}{
			"namespace": namespaceName,
		},
		NoColor: false,
	}
	defer common.DestroySelfSignedIssuer(t, selfSignedIssuerTerraformOptions)
	common.CreateSelfSignedIssuer(t, selfSignedIssuerTerraformOptions)

	// TEST CREATE ACME ISSUER
	acmeIssuerTerraformOptions := &terraform.Options{
		TerraformDir: "../../modules/common/cert-issuer",
		Vars: map[string]interface{}{
			"namespace": namespaceName,
		},
		NoColor: false,
	}
	defer common.DestroyAcmeIssuer(t, acmeIssuerTerraformOptions)
	common.CreateAcmeIssuer(t, acmeIssuerTerraformOptions)

	// TEST CREATE CA ISSUER
	caIssuerTerraformOptions := &terraform.Options{
		TerraformDir: "../../modules/common/ca-issuer",
		Vars: map[string]interface{}{
			"namespace": namespaceName,
		},
		NoColor: false,
	}
	defer common.DestroyCaIssuer(t, caIssuerTerraformOptions)
	common.CreateCaIssuer(t, caIssuerTerraformOptions)

	// TEST CREATE CERTIFICATE
	certificateTerraformOptions := &terraform.Options{
		TerraformDir: "../../modules/common/certificates",
		Vars: map[string]interface{}{
			"namespace": namespaceName,
		},
		NoColor: false,
	}
	defer common.DestroyCertificate(t, certificateTerraformOptions)
	common.CreateCertificate(t, certificateTerraformOptions)
}
