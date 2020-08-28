provider "kubernetes" {
  config_path = var.kube_config_path
}

provider "helm" {
  version = "1.1.1"

  kubernetes {
    config_path = var.kube_config_path
  }
}

module "keycloak" {
  source                       = "../../../../modules/tools/keycloak"

  enable_keycloak              = true
  namespace                    = var.namespace
  cluster                      = var.cluster
  root_zone_name               = var.root_zone_name
  postgres_password            = var.postgres_password
  keycloak_admin_password      = var.keycloak_admin_password
}
