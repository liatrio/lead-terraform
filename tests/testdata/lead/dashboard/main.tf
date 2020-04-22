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
  source                           = "../../../../modules/lead/dashboard"
  namespace                        = var.namespace
  root_zone_name                   = var.root_zone_name
  cluster                          = var.cluster_id
  cluster_domain                   = var.cluster_domain
  crd_waiter                       = var.crd_waiter
  dashboard_version                = var.dashboard_version
  keycloak_realm_id                = ""
  k8s_storage_class                = var.k8s_storage_class
  local                            = var.local
  keycloak_admin_credential_secret = ""
  toolchain_namespace              = ""
}
