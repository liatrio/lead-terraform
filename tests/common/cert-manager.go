package common

import (
	"testing"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/stretchr/testify/assert"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

func CreateCertManager(tm *TestModule) {
	namespace := tm.GetTerraformVar("namespace")
	kubeConfigPath := tm.GetStringGlobal(KubeConfigPath)
	k8sOptions := k8s.NewKubectlOptions("", kubeConfigPath, namespace)

	pods := k8s.ListPods(tm.GoTest, k8sOptions, metav1.ListOptions{ LabelSelector: "app.kubernetes.io/instance=cert-manager" })
	assert.Equal(tm.GoTest, 3, len(pods))
	services := k8s.ListServices(tm.GoTest, k8sOptions, metav1.ListOptions{ LabelSelector: "app.kubernetes.io/instance=cert-manager" })
	assert.Equal(tm.GoTest, 2, len(services))
}

func DestroyCertManager(tm *TestModule) {
	kubeConfigPath := tm.GetStringGlobal(KubeConfigPath)
	k8sOptions := k8s.NewKubectlOptions("", kubeConfigPath, "")

	_ = k8s.KubectlDeleteFromStringE(tm.GoTest, k8sOptions, `{"apiVersion": "admissionregistration.k8s.io/v1beta1",	"kind": "ValidatingWebhookConfiguration", "metadata": { "name": "cert-manager-webhook" } }`)
	_ = k8s.KubectlDeleteFromStringE(tm.GoTest, k8sOptions, `{"apiVersion": "admissionregistration.k8s.io/v1beta1",	"kind": "MutatingWebhookConfiguration", "metadata": { "name": "cert-manager-webhook" } }`)
	_ = k8s.KubectlDeleteFromStringE(tm.GoTest, k8sOptions, `{"apiVersion": "apiregistration.k8s.io/v1", "kind": "APIService", "metadata": { "name": "v1beta1.webhook.cert-manager.io" } }`)
	_ = k8s.KubectlDeleteFromStringE(tm.GoTest, k8sOptions, `{"apiVersion": "apiextensions.k8s.io/v1beta1",	"kind": "CustomResourceDefinition", "metadata": { "name": "challenges.acme.cert-manager.io" } }`)
	_ = k8s.KubectlDeleteFromStringE(tm.GoTest, k8sOptions, `{"apiVersion": "apiextensions.k8s.io/v1beta1",	"kind": "CustomResourceDefinition", "metadata": { "name": "certificaterequests.cert-manager.io" } }`)
	_ = k8s.KubectlDeleteFromStringE(tm.GoTest, k8sOptions, `{"apiVersion": "apiextensions.k8s.io/v1beta1",	"kind": "CustomResourceDefinition", "metadata": { "name": "certificates.cert-manager.io" } }`)
	_ = k8s.KubectlDeleteFromStringE(tm.GoTest, k8sOptions, `{"apiVersion": "apiextensions.k8s.io/v1beta1",	"kind": "CustomResourceDefinition", "metadata": { "name": "clusterissuers.cert-manager.io" } }`)
	_ = k8s.KubectlDeleteFromStringE(tm.GoTest, k8sOptions, `{"apiVersion": "apiextensions.k8s.io/v1beta1",	"kind": "CustomResourceDefinition", "metadata": { "name": "issuers.cert-manager.io" } }`)
	_ = k8s.KubectlDeleteFromStringE(tm.GoTest, k8sOptions, `{"apiVersion": "apiextensions.k8s.io/v1beta1",	"kind": "CustomResourceDefinition", "metadata": { "name": "orders.acme.cert-manager.io" } }`)
	_ = k8s.KubectlDeleteFromStringE(tm.GoTest, k8sOptions, `{"apiVersion": "rbac.authorization.k8s.io/v1",	"kind": "ClusterRole", "metadata": { "name": "cert-manager-cainjector" } }`)
	_ = k8s.KubectlDeleteFromStringE(tm.GoTest, k8sOptions, `{"apiVersion": "rbac.authorization.k8s.io/v1",	"kind": "ClusterRole", "metadata": { "name": "cert-manager-controller-certificates" } }`)
	_ = k8s.KubectlDeleteFromStringE(tm.GoTest, k8sOptions, `{"apiVersion": "rbac.authorization.k8s.io/v1",	"kind": "ClusterRole", "metadata": { "name": "cert-manager-controller-challenges" } }`)
	_ = k8s.KubectlDeleteFromStringE(tm.GoTest, k8sOptions, `{"apiVersion": "rbac.authorization.k8s.io/v1",	"kind": "ClusterRole", "metadata": { "name": "cert-manager-controller-clusterissuers" } }`)
	_ = k8s.KubectlDeleteFromStringE(tm.GoTest, k8sOptions, `{"apiVersion": "rbac.authorization.k8s.io/v1",	"kind": "ClusterRole", "metadata": { "name": "cert-manager-controller-ingress-shim" } }`)
	_ = k8s.KubectlDeleteFromStringE(tm.GoTest, k8sOptions, `{"apiVersion": "rbac.authorization.k8s.io/v1",	"kind": "ClusterRole", "metadata": { "name": "cert-manager-controller-issuers" } }`)
	_ = k8s.KubectlDeleteFromStringE(tm.GoTest, k8sOptions, `{"apiVersion": "rbac.authorization.k8s.io/v1",	"kind": "ClusterRole", "metadata": { "name": "cert-manager-controller-orders" } }`)
	_ = k8s.KubectlDeleteFromStringE(tm.GoTest, k8sOptions, `{"apiVersion": "rbac.authorization.k8s.io/v1",	"kind": "ClusterRole", "metadata": { "name": "cert-manager-edit" } }`)
	_ = k8s.KubectlDeleteFromStringE(tm.GoTest, k8sOptions, `{"apiVersion": "rbac.authorization.k8s.io/v1",	"kind": "ClusterRole", "metadata": { "name": "cert-manager-view" } }`)
	_ = k8s.KubectlDeleteFromStringE(tm.GoTest, k8sOptions, `{"apiVersion": "rbac.authorization.k8s.io/v1",	"kind": "ClusterRole", "metadata": { "name": "cert-manager-webhook:webhook-requester" } }`)
	_ = k8s.KubectlDeleteFromStringE(tm.GoTest, k8sOptions, `{"apiVersion": "rbac.authorization.k8s.io/v1",	"kind": "ClusterRoleBinding", "metadata": { "name": "cert-manager-cainjector" } }`)
	_ = k8s.KubectlDeleteFromStringE(tm.GoTest, k8sOptions, `{"apiVersion": "rbac.authorization.k8s.io/v1",	"kind": "ClusterRoleBinding", "metadata": { "name": "cert-manager-controller-certificates" } }`)
	_ = k8s.KubectlDeleteFromStringE(tm.GoTest, k8sOptions, `{"apiVersion": "rbac.authorization.k8s.io/v1",	"kind": "ClusterRoleBinding", "metadata": { "name": "cert-manager-controller-challenges" } }`)
	_ = k8s.KubectlDeleteFromStringE(tm.GoTest, k8sOptions, `{"apiVersion": "rbac.authorization.k8s.io/v1",	"kind": "ClusterRoleBinding", "metadata": { "name": "cert-manager-controller-clusterissuers" } }`)
	_ = k8s.KubectlDeleteFromStringE(tm.GoTest, k8sOptions, `{"apiVersion": "rbac.authorization.k8s.io/v1",	"kind": "ClusterRoleBinding", "metadata": { "name": "cert-manager-controller-ingress-shim" } }`)
	_ = k8s.KubectlDeleteFromStringE(tm.GoTest, k8sOptions, `{"apiVersion": "rbac.authorization.k8s.io/v1",	"kind": "ClusterRoleBinding", "metadata": { "name": "cert-manager-controller-issuers" } }`)
	_ = k8s.KubectlDeleteFromStringE(tm.GoTest, k8sOptions, `{"apiVersion": "rbac.authorization.k8s.io/v1",	"kind": "ClusterRoleBinding", "metadata": { "name": "cert-manager-controller-orders" } }`)
	_ = k8s.KubectlDeleteFromStringE(tm.GoTest, k8sOptions, `{"apiVersion": "rbac.authorization.k8s.io/v1",	"kind": "ClusterRoleBinding", "metadata": { "name": "cert-manager-webhook:auth-delegator" } }`)

	k8sOptions = k8s.NewKubectlOptions("", kubeConfigPath, "kube-system")
	_ = k8s.KubectlDeleteFromStringE(tm.GoTest, k8sOptions, `{"apiVersion": "rbac.authorization.k8s.io/v1",	"kind": "RoleBinding", "metadata": { "namespace": "kube-system", "name": "cert-manager-webhook:webhook-authentication-reader" } }`)
}

func SelfSignedIssuerSetup(t *TestModule) {
	t.SetTerraformVar("issuer_type", "selfSigned")
	t.SetTerraformVar("issuer_name", "testSelfSigned")
	t.SetTerraformVar("crd_waiter", "NA")
}

func SelfSignedIssuerRun(t *TestModule) {
	t.GoTest.Log("Self Signed Issuer Run")
}

func SelfSignedIssuerTeardown(t *TestModule) {
	t.GoTest.Log("Self Signed Issuer Teardown")
}

func CreateSelfSignedIssuer(t *testing.T, terraformOptions *terraform.Options) {
	terraformOptions.Vars["issuer_type"] = "selfSigned"
	terraformOptions.Vars["issuer_name"] = "testSelfSigned"
	terraformOptions.Vars["crd_waiter"] = "NA"
	terraform.InitAndApply(t, terraformOptions)
}

func DestroySelfSignedIssuer(t *testing.T, terraformOptions *terraform.Options) {
	terraform.Destroy(t, terraformOptions)
}

func CreateAcmeIssuer(t *testing.T, terraformOptions *terraform.Options) {
	terraformOptions.Vars["issuer_type"] = "acme"
	terraformOptions.Vars["issuer_name"] = "testAcme"
	terraformOptions.Vars["crd_waiter"] = "NA"
	terraform.InitAndApply(t, terraformOptions)
}

func DestroyAcmeIssuer(t *testing.T, terraformOptions *terraform.Options) {
	terraform.Destroy(t, terraformOptions)
}

func CreateCaIssuer(t *testing.T, terraformOptions *terraform.Options) {
	terraformOptions.Vars["name"] = "test-ca-issuer"
	terraformOptions.Vars["cert-manager-crd"] = "NA"
	terraformOptions.Vars["common_name"] = "test.lead-terraform.liatr.io"
	terraform.InitAndApply(t, terraformOptions)
}

func DestroyCaIssuer(t *testing.T, terraformOptions *terraform.Options) {
	terraform.Destroy(t, terraformOptions)
}

func CreateCertificate(t *testing.T, terraformOptions *terraform.Options) {
	terraformOptions.Vars["name"] = "test-certificate"
	terraformOptions.Vars["certificate_crd"] = "NA"
	terraformOptions.Vars["domain"] = "test.lead-terraform.liatr.io"
	terraformOptions.Vars["issuer_name"] = "test-ca-issuer"
	terraform.InitAndApply(t, terraformOptions)
}

func DestroyCertificate(t *testing.T, terraformOptions *terraform.Options) {
	terraform.Destroy(t, terraformOptions)
}
