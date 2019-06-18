
module "production_namespace" {
  source     = "../../common/namespace"
  namespace  = "${var.product_name}-production"
  annotations {
    name  = "${var.product_name}-production"
    "opa.lead.liatrio/ingress-whitelist" = "*.${var.product_name}-production.${var.cluster_domain}"
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
  crd_waiter  = ""

  providers {
    helm = "helm.production"
  }
}