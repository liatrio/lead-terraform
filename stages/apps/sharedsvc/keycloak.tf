data "vault_generic_secret" "keycloak" {
  path = "lead/aws/${data.aws_caller_identity.current.account_id}/keycloak"
}

locals {
  keycloak_realm      = "liatrio"
  keycloak_issuer_uri = "https://${module.keycloak.keycloak_hostname}/auth/realms/${local.keycloak_realm}"
  keycloak_token_uri  = "https://${module.keycloak.keycloak_hostname}/auth/realms/${local.keycloak_realm}/protocol/openid-connect/token"
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
