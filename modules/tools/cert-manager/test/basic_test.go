package test

import (
	"crypto/x509"
	"encoding/pem"
	"fmt"
	"os"
	"path"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	ts "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	v1 "k8s.io/api/core/v1"
)

func TestCertManager_Basic(t *testing.T) {
	t.Parallel()

	testingDnsZone := "lead.sandbox.liatr.io"
	oidcProviderArn := getRequiredEnvVar(t, "OIDC_PROVIDER_ARN")
	oidcProviderUrl := getRequiredEnvVar(t, "OIDC_PROVIDER_URL")

	defer ts.RunTestStage(t, "delete_testdata", func() {
		if err := os.RemoveAll(".test-data"); err != nil {
			t.Errorf("error removing test data: %s", err)
		}
	})

	defer ts.RunTestStage(t, "delete_namespace", func() {
		k8sOpts := ts.LoadKubectlOptions(t, ".")
		namespace := ts.LoadString(t, ".", "namespace")
		if namespace != "" {
			k8s.DeleteNamespace(t, k8sOpts, namespace)
		}
	})

	defer ts.RunTestStage(t, "destroy_terraform", func() {
		terraformOpts := ts.LoadTerraformOptions(t, ".")
		terraform.Destroy(t, terraformOpts)
	})

	ts.RunTestStage(t, "create_namespace", func() {
		namespace := fmt.Sprintf("terratest-%s", strings.ToLower(random.UniqueId()))
		ts.SaveString(t, ".", "namespace", namespace)

		kubectlOptions := k8s.NewKubectlOptions("", "", namespace)
		ts.SaveKubectlOptions(t, ".", kubectlOptions)
		k8s.CreateNamespace(t, kubectlOptions, namespace)
	})

	ts.RunTestStage(t, "terraform", func() {
		//expectedStatus := "deployed"
		// TODO: move terraform to tmpdir along with module dependencies
		tfdir := path.Join(".", "fixtures", "basic")
		namespace := ts.LoadString(t, ".", "namespace")
		terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
			TerraformDir: tfdir,
			Vars: map[string]interface{}{
				"namespace": namespace,
				"cluster":   namespace,
				// TODO: use a separate domain for testing
				"hosted_zone_name":  testingDnsZone,
				"oidc_provider_arn": oidcProviderArn,
				"oidc_provider_url": oidcProviderUrl,
			},
			NoColor: true,
		})
		ts.SaveTerraformOptions(t, ".", terraformOptions)
		terraform.InitAndApply(t, terraformOptions)

		//
		//actualNamespace := terraform.Output(t, terraformOptions, "namespace")
		//actualStatus := terraform.Output(t, terraformOptions, "status")
		//
		//assert.Equal(t, namespace, actualNamespace)
		//assert.Equal(t, expectedStatus, actualStatus)
	})

	ts.RunTestStage(t, "validate_certificate", func() {
		namespace := ts.LoadString(t, ".", "namespace")
		expectedHost := fmt.Sprintf("%s.%s", namespace, testingDnsZone)
		k8sOpts := ts.LoadKubectlOptions(t, ".")

		certificateSecret := k8s.GetSecret(t, k8sOpts, "terratest")

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

		assert.Len(t, cert.Issuer.Organization, 1)
		assert.Equal(t, "(STAGING) Let's Encrypt", cert.Issuer.Organization[0])
		if err = cert.VerifyHostname(expectedHost); err != nil {
			t.Fatalf("cannot verify that expected hostname is valid for certificate: %s", err)
		}
	})
}

func getRequiredEnvVar(t *testing.T, varName string) string {
	envVar := os.Getenv(varName)
	if envVar == "" {
		t.Fatalf("expected environment variable '%s' to be set, but wasn't", varName)
	}

	return envVar
}
