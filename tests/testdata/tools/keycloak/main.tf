provider "kubernetes" {
  config_path = var.kube_config_path
}

provider "helm" {
  version = "1.1.1"

  kubernetes {
    config_path = var.kube_config_path
  }
}

#tfsec:ignore:general-secrets-sensitive-in-attribute
module "keycloak" {
  source = "../../../../modules/tools/keycloak"

  namespace               = var.namespace
  cluster_domain          = "${var.cluster}.${var.root_zone_name}"
  postgres_password       = var.postgres_password
  keycloak_admin_password = var.keycloak_admin_password
}
