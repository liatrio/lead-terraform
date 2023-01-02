locals {
  vault_hostname = "vault.${var.internal_cluster_domain}"
}

module "vault_namespace" {
  source      = "../../../modules/common/namespace"
  namespace   = "vault"
  annotations = {
    name    = "vault"
    cluster = var.eks_cluster_id
  }
}

module "vault" {
  source = "../../../modules/tools/vault"

  cert_issuer_kind            = module.internal_services_cluster_issuer.issuer_kind
  cert_issuer_name            = module.internal_services_cluster_issuer.issuer_name
  namespace                   = module.vault_namespace.name
  region                      = var.region
  vault_hostname              = local.vault_hostname
  vault_dynamodb_table_name   = local.vault_hostname
  vault_aws_access_key_id     = var.vault_aws_access_key_id
  vault_aws_secret_access_key = var.vault_aws_secret_access_key
  vault_kms_key_id            = var.vault_kms_key_id
#  vault_iam_role_arn          = var.vault_iam_role_arn
}
