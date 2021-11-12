package test

import (
	"crypto/x509"
	"encoding/pem"
	"fmt"
	"os"
	"path"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	ts "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	v1 "k8s.io/api/core/v1"
)

func TestCertManager_Basic(t *testing.T) {
	t.Parallel()

	// TODO: use a separate domain for testing
	testingDnsZone := "lead.sandbox.liatr.io"
	oidcProviderArn := getRequiredEnvVar(t, "OIDC_PROVIDER_ARN")
	oidcProviderUrl := getRequiredEnvVar(t, "OIDC_PROVIDER_URL")

	defer ts.RunTestStage(t, "delete testdata", func() {
		if err := os.RemoveAll(".test-data"); err != nil {
			t.Errorf("error removing test data: %s", err)
		}
	})

	defer ts.RunTestStage(t, "delete namespace1", func() {
		k8sOpts := ts.LoadKubectlOptions(t, ".")
		namespace := ts.LoadString(t, ".", "namespace")
		if namespace != "" {
			k8s.DeleteNamespace(t, k8sOpts, namespace)
		}
	})

	defer ts.RunTestStage(t, "destroy terraform", func() {
		k8sOpts := ts.LoadKubectlOptions(t, ".")

		// clean up cert-manager resources generated by the controller; otherwise the namespace
		// will get stuck terminating while waiting on custom resource finalizers to run.
		k8s.RunKubectl(t, k8sOpts, "delete", "CertificateRequests,Orders,Challenges", "--all")

		terraformOpts := ts.LoadTerraformOptions(t, ".")
		terraform.Destroy(t, terraformOpts)
	})

	ts.RunTestStage(t, "create namespace", func() {
		namespace := fmt.Sprintf("test-%s", strings.ToLower(random.UniqueId()))
		ts.SaveString(t, ".", "namespace", namespace)

		kubectlOptions := k8s.NewKubectlOptions("", "", namespace)
		configPath, err := kubectlOptions.GetConfigPath(t)
		if err != nil {
			t.Fatal(err)
		}

		kubectlOptions.ConfigPath = configPath

		ts.SaveKubectlOptions(t, ".", kubectlOptions)
		k8s.CreateNamespace(t, kubectlOptions, namespace)
	})

	ts.RunTestStage(t, "terraform", func() {
		// TODO: move terraform to tmpdir along with module dependencies
		kubectlOptions := ts.LoadKubectlOptions(t, ".")
		tfdir := path.Join(".", "fixtures", "basic")
		namespace := ts.LoadString(t, ".", "namespace")
		terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
			TerraformDir: tfdir,
			Vars: map[string]interface{}{
				"namespace":         namespace,
				"cluster":           namespace,
				"hosted_zone_name":  testingDnsZone,
				"oidc_provider_arn": oidcProviderArn,
				"oidc_provider_url": oidcProviderUrl,
				"kubeconfig_path":   kubectlOptions.ConfigPath,
			},
			NoColor: true,
		})
		ts.SaveTerraformOptions(t, ".", terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	ts.RunTestStage(t, "validate certificate", func() {
		namespace := ts.LoadString(t, ".", "namespace")
		expectedHost := fmt.Sprintf("%s.%s", namespace, testingDnsZone)

		k8sOpts := ts.LoadKubectlOptions(t, ".")
		terraformOptions := ts.LoadTerraformOptions(t, ".")
		secretName := terraform.Output(t, terraformOptions, "certificate_secret_name")
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

		t.Fatalf("expected certificate order to have completed by now")
	})
}

func getRequiredEnvVar(t *testing.T, varName string) string {
	envVar := os.Getenv(varName)
	if envVar == "" {
		t.Fatalf("expected environment variable '%s' to be set, but wasn't", varName)
	}

	return envVar
}
