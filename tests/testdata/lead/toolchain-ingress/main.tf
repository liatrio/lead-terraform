provider "kubernetes" {
  config_path            = var.kube_config_path
}

provider "helm" {
  version         = "1.1.0"

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
  ingress_controller_type = var.ingress_controller_type
}
