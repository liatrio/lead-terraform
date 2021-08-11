module "product_base" {
  source          = "../product-base"
  cluster_domain  = var.cluster_domain
  product_name    = var.product_name
  image_whitelist = var.image_whitelist

  vault_namespace         = var.vault_namespace
  vault_root_token_secret = var.vault_root_token_secret
  vault_external          = var.vault_external

  providers = {
    helm.staging          = helm.staging
    kubernetes.staging    = kubernetes.staging
    helm.production       = helm.production
    kubernetes.production = kubernetes.production
    helm.system           = helm.system
    kubernetes.system     = kubernetes.system
  }
}
