
module "production_namespace" {
  source     = "../../common/namespace"
  namespace  = "${var.product_name}-production"
  issuer_type = "${var.issuer_type}"
  annotations {
    name  = "${var.product_name}-production"
    cluster = "${var.cluster}"
    "opa.lead.liatrio/ingress-whitelist" = "*.${var.product_name}-production.${var.cluster}.${var.root_zone_name}"
    "opa.lead.liatrio/image-whitelist" = "${var.image_whitelist}"
  }
  providers {
    helm = "helm.production"
    kubernetes = "kubernetes.production"
  }
}
