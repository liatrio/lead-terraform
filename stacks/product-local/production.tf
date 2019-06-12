provider "kubernetes" {
  alias = "production"
  config_context = "${var.cluster}"
}

provider "helm" {
  alias = "production"
  namespace = "${module.production_namespace.name}"
  tiller_image = "gcr.io/kubernetes-helm/tiller:v2.14.1"
  service_account = "${module.production_namespace.tiller_service_account}"

  kubernetes {
    config_context = "${var.cluster}"
  }
}

module "production_namespace" {
  source     = "../../modules/common/namespace"
  namespace  = "${var.product_name}-production"
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