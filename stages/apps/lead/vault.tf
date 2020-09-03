module "vault" {
  source = "../../../modules/tools/vault-less-secure"

  count                       = var.enable_vault ? 1 : 0
  namespace                   = var.toolchain_namespace
  region                      = var.region
  vault_dynamodb_table_name   = var.vault_dynamodb_table_name
  vault_hostname              = "vault.${var.toolchain_namespace}.${var.cluster_name}.${var.root_zone_name}"
  vault_aws_access_key_id     = var.vault_aws_access_key_id
  vault_aws_secret_access_key = var.vault_aws_secret_access_key
  vault_kms_key_id            = var.vault_kms_key_id
}
