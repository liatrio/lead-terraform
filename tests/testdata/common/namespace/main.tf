provider "kubernetes" {
  config_path            = var.kube_config_path
}

module "namespace" {
  source = "../../../../modules/common/namespace"
  namespace = var.namespace
}
