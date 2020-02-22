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

	namespaceName := fmt.Sprintf("test-cert-manager-%s", strings.ToLower(random.UniqueId()))

	options := k8s.NewKubectlOptions("", "", namespaceName)

	defer k8s.DeleteNamespace(t, options, namespaceName)
	k8s.CreateNamespace(t, options, namespaceName)

	// TEST CREATE CERT-MANAGER
	certManagerTerraformOptions := &terraform.Options{
		TerraformDir: "../../modules/tools/cert-manager",
		Vars: map[string]interface{}{
			"namespace": namespaceName,
			"tiller_cluster_role_binding": "NA",
		},
		NoColor: false,
	}
	defer common.DestroyCertManager(t, certManagerTerraformOptions, options)
	common.CreateCertManager(t, certManagerTerraformOptions, options)


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
