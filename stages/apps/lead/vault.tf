locals {
  lead_vault_hostname = "vault.${var.toolchain_namespace}.${var.cluster_name}.${var.root_zone_name}"
}

module "vault" {
  source = "../../../modules/tools/vault-less-secure"

  namespace                   = var.toolchain_namespace
  region                      = var.region
  vault_dynamodb_table_name   = var.vault_dynamodb_table_name
  vault_hostname              = local.lead_vault_hostname
  vault_aws_access_key_id     = var.vault_aws_access_key_id
  vault_aws_secret_access_key = var.vault_aws_secret_access_key
  vault_kms_key_id            = var.vault_kms_key_id
}

resource "kubernetes_service_account" "vault_token_reviewer" {
  metadata {
    name      = "vault-token-reviewer"
    namespace = var.toolchain_namespace
  }
}

resource "kubernetes_cluster_role_binding" "vault_token_reviewer" {
  metadata {
    name = "vault-tokenreview-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.vault_token_reviewer.metadata[0].name
    namespace = kubernetes_service_account.vault_token_reviewer.metadata[0].namespace
  }
}
