provider "kubernetes" {
  config_path = var.kube_config_path
}

provider "helm" {
  version = "1.1.1"

  kubernetes {
    config_path = var.kube_config_path
  }
}

module "kube_janitor" {
  source = "../../../../modules/tools/kube-janitor"

  namespace = var.namespace
}
