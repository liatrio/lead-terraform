module "vault_namespace" {
  source      = "../../../modules/common/namespace"
  namespace   = "vault"
  annotations = {
    name    = "vault"
    cluster = var.eks_cluster_id
  }
}

//module "vault" {
//  source = "../../../modules/tools/vault"
//
//  cert_crd_waiter           = ""
//  cert_issuer_kind          = ""
//  cert_issuer_name          = ""
//  cluster_domain            = var.cluster_domain
//  namespace                 = kubernetes_namespace.vault.metadata[0].name
//  region                    = var.region
//  vault_dynamodb_table_name = ""
//}
