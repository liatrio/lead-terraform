data "vault_generic_secret" "keycloak" {
  path = "lead/aws/${data.aws_caller_identity.current.account_id}/keycloak"
}

module "keycloak" {
  count      = var.enable_keycloak ? 1 : 0
  source = "../../../modules/tools/keycloak"

  namespace               = var.toolchain_namespace
  cluster_domain          = "${var.cluster_name}.${var.root_zone_name}"
  postgres_password       = data.vault_generic_secret.keycloak.data["postgres-password"]
  keycloak_admin_password = data.vault_generic_secret.keycloak.data["admin-password"]
}
