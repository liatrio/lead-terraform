module "vault" {
  source = "../../../modules/tools/vault-less-secure"

  namespace                 = var.toolchain_namespace
  region                    = var.region
  vault_dynamodb_table_name = "vault.${var.toolchain_namespace}.${var.cluster}.${var.root_zone_name}"
  vault_hostname            = "vault.${var.toolchain_namespace}.${var.cluster}.${var.root_zone_name}"
}
