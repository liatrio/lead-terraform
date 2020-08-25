provider "kubernetes" {
  config_path = var.kube_config_path
}

provider "helm" {
  version = "1.1.1"

  kubernetes {
    config_path = var.kube_config_path
  }
}

module "harbor" {
  source                       = "../../../../modules/tools/harbor"
  enable                       = true
  toolchain_namespace          = var.toolchain_namespace
  cluster                      = var.cluster
  root_zone_name               = var.root_zone_name
  harbor_registry_disk_size    = "2Gi"
  harbor_chartmuseum_disk_size = "2Gi"
  k8s_storage_class            = var.k8s_storage_class
  issuer_name                  = var.issuer_kind
  issuer_kind                  = var.issuer_name
  crd_waiter                   = true
}
