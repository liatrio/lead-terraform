provider "kubernetes" {
  config_path = var.kube_config_path
}

provider "helm" {
  version = "1.1.1"

  kubernetes {
    config_path = var.kube_config_path
  }
}

module "kube_downscaler" {
  source = "../../../../modules/tools/kube-downscaler"

  uptime              = var.uptime
  namespace           = var.namespace
  excluded_namespaces = [
    var.namespace
  ]
}
