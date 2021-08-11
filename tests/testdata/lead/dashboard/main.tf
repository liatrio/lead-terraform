provider "kubernetes" {
  config_path = var.kube_config_path
}

provider "helm" {
  version = "1.1.1"

  kubernetes {
    config_path = var.kube_config_path
  }
}

module "dashboard" {
  source = "../../../../modules/lead/dashboard"

  enabled           = true
  namespace         = var.namespace
  dashboard_version = var.dashboard_version
}
