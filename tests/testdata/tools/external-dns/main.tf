provider "kubernetes" {
  config_path = var.kube_config_path
}

provider "helm" {
  version = "1.1.1"

  kubernetes {
    config_path = var.kube_config_path
  }
}

module "external_dns" {
  source = "../../../../modules/tools/external-dns"

  enabled        = true
  domain_filters = var.domain_filters
  namespace      = var.namespace
  istio_enabled  = var.istio_enabled
}
