provider "kubernetes" {
  config_path            = var.kube_config_path
}

provider "helm" {
  version         = "1.1.1"

  kubernetes {
    config_path            = var.kube_config_path
  }
}

module "kube-resource-report" {
  source = "../../../../modules/tools/kube-resource-report"
  cluster = var.cluster
  namespace = var.namespace
  root_zone_name = var.root_zone_name
}
