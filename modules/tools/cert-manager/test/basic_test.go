package test

import (
	"crypto/x509"
	"encoding/pem"
	"fmt"
	"github.com/liatrio/lead-terraform/test/common"
	"path"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	v1 "k8s.io/api/core/v1"
)

func TestCertManager_Basic(t *testing.T) {
	t.Parallel()

	// TODO: use a separate domain for testing
	testingDnsZone := "lead.sandbox.liatr.io"
	oidcProviderArn := common.GetRequiredEnvVar(t, "OIDC_PROVIDER_ARN")
	oidcProviderUrl := common.GetRequiredEnvVar(t, "OIDC_PROVIDER_URL")

	namespace := common.CreateNamespace(t)

	defer common.Cleanup(t, func(t *testing.T, k8sOpts *k8s.KubectlOptions) {
		k8s.RunKubectl(t, k8sOpts, "delete", "CertificateRequests,Orders,Challenges", "--all")
	})

	common.RunTerraform(t, path.Join(".", "fixtures", "basic"), func(k8sOpts *k8s.KubectlOptions) map[string]interface{} {
		return map[string]interface{}{
			"namespace":         namespace,
			"cluster":           namespace,
			"hosted_zone_name":  testingDnsZone,
			"oidc_provider_arn": oidcProviderArn,
			"oidc_provider_url": oidcProviderUrl,
			"kubeconfig_path":   k8sOpts.ConfigPath,
		}
	})

	common.RunTestStage(t, "validate certificate", func(k8sOpts *k8s.KubectlOptions, terraformOpts *terraform.Options) {
		expectedHost := fmt.Sprintf("%s.%s", namespace, testingDnsZone)
		secretName := terraform.Output(t, terraformOpts, "certificate_secret_name")

		for i := 0; i < 10; i++ {
			certificateSecret := k8s.GetSecret(t, k8sOpts, secretName)
			assert.Equal(t, v1.SecretTypeTLS, certificateSecret.Type)
			decodedCertificate, _ := pem.Decode(certificateSecret.Data["tls.crt"])
			// failed to parse
			if decodedCertificate == nil {
				t.Fatalf("failed to parse certificate")
			}

			cert, err := x509.ParseCertificate(decodedCertificate.Bytes)
			if err != nil {
				t.Fatalf("error parsing certificate: %s", err)
			}

			// the certificate module requests a temporary certificate until the actual order completes
			// it usually takes 5-6 minutes for the actual certificate to be present in the secret, so we poll until then
			if cert.Issuer.CommonName == "cert-manager.local" {
				t.Log("issuer value indicates a temporary certificate, waiting before checking again")
				time.Sleep(time.Minute)
				continue
			}

			if len(cert.Issuer.Organization) != 1 {
				t.Fatalf("expected cert organization to be present")
			}

			assert.Equal(t, "(STAGING) Let's Encrypt", cert.Issuer.Organization[0])
			if err = cert.VerifyHostname(expectedHost); err != nil {
				t.Fatalf("cannot verify that expected hostname is valid for certificate: %s", err)
			}

			return
		}
	})
}
