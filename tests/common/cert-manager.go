package common

import (
	"testing"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/stretchr/testify/assert"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

func createCertManager(t *testing.T, terraformOptions *terraform.Options, k8sOptions *k8s.KubectlOptions) {
	terraform.InitAndApply(t, terraformOptions)

	pods := k8s.ListPods(t, k8sOptions, metav1.ListOptions{ LabelSelector: "app.kubernetes.io/instance=cert-manager" })
	assert.Equal(t, 3, len(pods))
	services := k8s.ListServices(t, k8sOptions, metav1.ListOptions{ LabelSelector: "app.kubernetes.io/instance=cert-manager" })
	assert.Equal(t, 2, len(services))
}

func destroyCertManager(t *testing.T, terraformOptions *terraform.Options, k8sOptions *k8s.KubectlOptions) {
	terraform.Destroy(t, terraformOptions)
	_ = k8s.KubectlDeleteFromStringE(t, k8sOptions, `{"apiVersion": "apiextensions.k8s.io/v1beta1",	"kind": "CustomResourceDefinition", "metadata": { "name": "challenges.acme.cert-manager.io" } }`)
	_ = k8s.KubectlDeleteFromStringE(t, k8sOptions, `{"apiVersion": "apiextensions.k8s.io/v1beta1",	"kind": "CustomResourceDefinition", "metadata": { "name": "certificaterequests.cert-manager.io" } }`)
	_ = k8s.KubectlDeleteFromStringE(t, k8sOptions, `{"apiVersion": "apiextensions.k8s.io/v1beta1",	"kind": "CustomResourceDefinition", "metadata": { "name": "certificates.cert-manager.io" } }`)
	_ = k8s.KubectlDeleteFromStringE(t, k8sOptions, `{"apiVersion": "apiextensions.k8s.io/v1beta1",	"kind": "CustomResourceDefinition", "metadata": { "name": "clusterissuers.cert-manager.io" } }`)
	_ = k8s.KubectlDeleteFromStringE(t, k8sOptions, `{"apiVersion": "apiextensions.k8s.io/v1beta1",	"kind": "CustomResourceDefinition", "metadata": { "name": "issuers.cert-manager.io" } }`)
	_ = k8s.KubectlDeleteFromStringE(t, k8sOptions, `{"apiVersion": "apiextensions.k8s.io/v1beta1",	"kind": "CustomResourceDefinition", "metadata": { "name": "orders.acme.cert-manager.io" } }`)
}

func createSelfSignedIssuer(t *testing.T, terraformOptions *terraform.Options) {
	terraformOptions.Vars["issuer_type"] = "selfSigned"
	terraformOptions.Vars["issuer_name"] = "testSelfSigned"
	terraformOptions.Vars["crd_waiter"] = "NA"
	terraform.InitAndApply(t, terraformOptions)
}

func destroySelfSignedIssuer(t *testing.T, terraformOptions *terraform.Options) {
	terraform.Destroy(t, terraformOptions)
}

func createAcmeIssuer(t *testing.T, terraformOptions *terraform.Options) {
	terraformOptions.Vars["issuer_type"] = "acme"
	terraformOptions.Vars["issuer_name"] = "testAcme"
	terraformOptions.Vars["crd_waiter"] = "NA"
	terraform.InitAndApply(t, terraformOptions)
}

func destroyAcmeIssuer(t *testing.T, terraformOptions *terraform.Options) {
	terraform.Destroy(t, terraformOptions)
}

func createCaIssuer(t *testing.T, terraformOptions *terraform.Options) {
	terraformOptions.Vars["name"] = "test-ca-issuer"
	terraformOptions.Vars["cert-manager-crd"] = "NA"
	terraformOptions.Vars["common_name"] = "test.lead-terraform.liatr.io"
	terraform.InitAndApply(t, terraformOptions)
}

func destroyCaIssuer(t *testing.T, terraformOptions *terraform.Options) {
	terraform.Destroy(t, terraformOptions)
}

func createCertificate(t *testing.T, terraformOptions *terraform.Options) {
	terraformOptions.Vars["name"] = "test-certificate"
	terraformOptions.Vars["certificate_crd"] = "NA"
	terraformOptions.Vars["domain"] = "test.lead-terraform.liatr.io"
	terraformOptions.Vars["issuer_name"] = "test-ca-issuer"
	terraform.InitAndApply(t, terraformOptions)
}

func destroyCertificate(t *testing.T, terraformOptions *terraform.Options) {
	terraform.Destroy(t, terraformOptions)
}
