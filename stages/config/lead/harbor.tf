data "vault_generic_secret" "harbor" {
  provider = vault.main
  path     = "lead/aws/${data.aws_caller_identity.current.account_id}/harbor"
}

module "harbor_config" {
  count  = var.enable_harbor ? 1 : 0
  source = "../../../modules/config/harbor"

  namespace         = var.toolchain_namespace
  hostname          = var.harbor_hostname
  admin_password    = data.vault_generic_secret.harbor.data["admin-password"]
  enable_keycloak   = var.enable_keycloak
  keycloak_hostname = var.keycloak_hostname
  keycloak_realm    = module.keycloak_config.keycloak_realm_id
}
