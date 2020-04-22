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

  enabled       = true
  domain_filter = var.domain_filter
  namespace     = var.namespace
}
