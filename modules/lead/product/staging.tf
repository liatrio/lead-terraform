module "staging_namespace" {
  source     = "../../common/namespace"
  namespace  = "${var.product_name}-staging"
  annotations {
    name  = "${var.product_name}-staging"
    "opa.lead.liatrio/ingress-whitelist" = "*.${var.product_name}-staging.${var.cluster_domain}"
    "opa.lead.liatrio/image-whitelist" = "${var.image_whitelist}"
  }
  providers {
    helm = "helm.staging"
    kubernetes = "kubernetes.staging"
  }
}

module "staging_ingress" {
  source = "../../common/nginx-ingress"
  namespace  = "${module.staging_namespace.name}"
  ingress_controller_type = "${var.ingress_controller_type}"

  providers {
    helm = "helm.staging"
    kubernetes = "kubernetes.staging"
  }
}

module "staging_issuer" {
  source = "../../common/cert-issuer"
  namespace  = "${module.staging_namespace.name}"
  issuer_type = "${var.issuer_type}"
  crd_waiter  = ""

  providers {
    helm = "helm.staging"
  }
}
