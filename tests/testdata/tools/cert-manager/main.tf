provider "kubernetes" {
  config_path = var.kube_config_path
}

provider "helm" {
  version = "1.1.1"

  kubernetes {
    config_path = var.kube_config_path
  }
}

module "cert-manager" {
  source    = "../../../../modules/tools/cert-manager"
  namespace = var.namespace
}
