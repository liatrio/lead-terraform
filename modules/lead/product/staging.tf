module "staging_namespace" {
  source     = "../../common/namespace"
  namespace  = "${var.product_name}-staging"
  issuer_type = "${var.issuer_type}"
  annotations {
    name  = "${var.product_name}-staging"
    cluster = "${var.cluster}"
    "opa.lead.liatrio/ingress-whitelist" = "*.${var.product_name}-staging.${var.cluster}.${var.root_zone_name}"
    "opa.lead.liatrio/image-whitelist" = "${var.image_whitelist}"
  }
  providers {
    helm = "helm.staging"
    kubernetes = "kubernetes.staging"
  }
}
