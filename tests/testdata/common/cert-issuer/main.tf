provider "kubernetes" {
  config_path            = var.kube_config_path
}

provider "helm" {
  # alias           = "toolchain"
  version         = "1.0.0"
  # namespace       = var.namespace
  # tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.15.1"
  # service_account = var.tiller_service_account

  kubernetes {
    config_path            = var.kube_config_path
  }
}

module "cert_issuer" {
  source = "../../../../modules/common/cert-issuer"
  namespace = var.namespace
  issuer_kind = var.issuer_kind
  issuer_name = var.issuer_name
  issuer_type = var.issuer_type
  crd_waiter  = var.crd_waiter
}
