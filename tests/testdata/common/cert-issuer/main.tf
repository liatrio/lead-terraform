provider "kubernetes" {
  config_path = var.kube_config_path
}

provider "helm" {
  version = "1.1.1"

  kubernetes {
    config_path = var.kube_config_path
  }
}

module "cert_issuer" {
  source      = "../../../../modules/common/cert-issuer"
  namespace   = var.namespace
  issuer_kind = var.issuer_kind
  issuer_name = var.issuer_name
  issuer_type = var.issuer_type
}
