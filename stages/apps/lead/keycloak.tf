data "vault_generic_secret" "keycloak" {
  path = "lead/aws/${data.aws_caller_identity.current.account_id}/keycloak"
}

module "keycloak" {
  source = "../../modules/tools/keycloak"

  enable_keycloak         = var.enable_keycloak
  namespace               = module.toolchain.namespace
  cluster                 = var.cluster
  root_zone_name          = var.root_zone_name
  postgres_password       = data.vault_generic_secret.keycloak.data["postgres-password"]
  keycloak_admin_password = data.vault_generic_secret.keycloak.data["admin-password"]
}
