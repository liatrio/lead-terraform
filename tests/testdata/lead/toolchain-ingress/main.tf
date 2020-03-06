provider "kubernetes" {
  config_path            = var.kube_config_path
}

provider "helm" {
  version         = "0.10.4"
  namespace       = var.namespace
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.15.1"
  service_account = var.tiller_service_account

  kubernetes {
    config_path            = var.kube_config_path
  }
}

module "ingress" {
  source = "../../../../modules/lead/toolchain-ingress"
  namespace = var.namespace
  issuer_kind = var.issuer_kind
  issuer_name = var.issuer_name
  cluster_domain = var.cluster_domain
  crd_waiter = var.crd_waiter
}
