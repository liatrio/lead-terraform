provider "kubernetes" {
  config_path = var.kube_config_path
}

provider "helm" {
  version = "1.1.1"

  kubernetes {
    config_path = var.kube_config_path
  }
}

module "k8s_spot_termination_handler" {
  source = "../../../../modules/tools/k8s-spot-termination-handler"

  namespace = var.namespace
}
