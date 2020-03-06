package common

import(
	"github.com/gruntwork-io/terratest/modules/k8s"
)

func SdmSetup(tm *TestModule) {

}

func SdmRun(tm *TestModule) {

}

func SdmTeardown(t *TestModule) {
	k8sOptions := k8s.NewKubectlOptions("", t.GetStringGlobal(KubeConfigPath), t.GetTerraformVar("namespace"))

	_ = k8s.KubectlDeleteFromStringE(t.GoTest, k8sOptions, `{"apiVersion": "rbac.authorization.k8s.io/v1",	"kind": "ClusterRole", "metadata": { "name": "operator-slack-cluster-manager" } }`)
	_ = k8s.KubectlDeleteFromStringE(t.GoTest, k8sOptions, `{"apiVersion": "rbac.authorization.k8s.io/v1",	"kind": "ClusterRole", "metadata": { "name": "operator-jenkins-cluster-manager" } }`)
	_ = k8s.KubectlDeleteFromStringE(t.GoTest, k8sOptions, `{"apiVersion": "rbac.authorization.k8s.io/v1",	"kind": "ClusterRoleBinding", "metadata": { "name": "operator-slack-cluster-binding" } }`)
	_ = k8s.KubectlDeleteFromStringE(t.GoTest, k8sOptions, `{"apiVersion": "rbac.authorization.k8s.io/v1",	"kind": "ClusterRoleBinding", "metadata": { "name": "operator-jenkins-cluster-binding" } }`)
	_ = k8s.KubectlDeleteFromStringE(t.GoTest, k8sOptions, `{"apiVersion": "apiextensions.k8s.io/v1beta1",	"kind": "CustomResourceDefinition", "metadata": { "name": "builds.stable.liatr.io" } }`)
	_ = k8s.KubectlDeleteFromStringE(t.GoTest, k8sOptions, `{"apiVersion": "apiextensions.k8s.io/v1beta1",	"kind": "CustomResourceDefinition", "metadata": { "name": "products.stable.liatr.io" } }`)
	_ = k8s.KubectlDeleteFromStringE(t.GoTest, k8sOptions, `{"apiVersion": "apiextensions.k8s.io/v1beta1",	"kind": "CustomResourceDefinition", "metadata": { "name": "toolchains.stable.liatr.io" } }`)
}