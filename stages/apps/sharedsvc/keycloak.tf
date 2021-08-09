data "vault_generic_secret" "keycloak" {
  path = "lead/aws/${data.aws_caller_identity.current.account_id}/keycloak"
}

module "keycloak_namespace" {
  source    = "../../../modules/common/namespace"
  namespace = "keycloak"
}

module "keycloak" {
  source = "../../../modules/tools/keycloak"

  namespace               = module.keycloak_namespace.name
  cluster_domain          = var.cluster_domain
  postgres_password       = data.vault_generic_secret.keycloak.data["postgres-password"]
  keycloak_admin_password = data.vault_generic_secret.keycloak.data["admin-password"]
  ingress_class           = module.nginx_external.ingress_class
}
