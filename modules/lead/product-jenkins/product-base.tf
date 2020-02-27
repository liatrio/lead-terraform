module "product_base" {
  source    = "../product-base"
  cluster_domain = var.cluster_domain
  product_name = var.product_name
  image_whitelist = var.image_whitelist

  providers = {
    helm.staging = helm.staging
    kubernetes.staging = kubernetes.staging
    helm.production = helm.production
    kubernetes.production = kubernetes.production
  }
}
