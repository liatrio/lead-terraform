module "vault" {
  source = "../../modules/tools/vault-less-secure"

  namespace                 = module.toolchain.namespace
  region                    = var.region
  vault_dynamodb_table_name = "vault.toolchain.${module.eks.cluster_id}.${var.root_zone_name}"
  vault_hostname            = "vault.toolchain.${module.eks.cluster_id}.${var.root_zone_name}"
}
