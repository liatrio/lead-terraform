provider "kubernetes" {
  config_path            = var.kube_config_path
}

provider "helm" {
  version         = "0.10.4"
  namespace       = var.namespace
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.15.1"
  service_account = var.tiller_service_account

  override = [
    "spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key=kubernetes.io/lifecycle",
    "spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].operator=NotIn",
    "spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0]=preemptible",
    "spec.template.spec.tolerations[0].key=${var.essential_taint_key}",
    "spec.template.spec.tolerations[0].operator=Exists",
    "spec.template.spec.containers[0].resources.limits.memory=400Mi",
    "spec.template.spec.containers[0].resources.requests.memory=100Mi",
    "spec.template.spec.containers[0].resources.limits.cpu=800m",
    "spec.template.spec.containers[0].resources.requests.cpu=100m",
  ]

  kubernetes {
    config_path            = var.kube_config_path
  }
}

module "cert-manager" {
  source = "../../../../modules/apps/cert-manager"
  namespace = var.namespace
  tiller_cluster_role_binding = var.tiller_cluster_role_binding
}
