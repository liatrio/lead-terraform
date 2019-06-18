
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

module "production_ingress" {
  source = "../../common/nginx-ingress"
  namespace  = "${module.production_namespace.name}"
  ingress_controller_type = "${var.ingress_controller_type}"

  providers {
    helm = "helm.production"
    kubernetes = "kubernetes.production"
  }
}

module "production_issuer" {
  source = "../../common/cert-issuer"
  namespace  = "${module.production_namespace.name}"
  issuer_type = "${var.issuer_type}"

  providers {
    helm = "helm.production"
  }
}