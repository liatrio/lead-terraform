provider "kubernetes" {
  alias = "staging"
  config_context = "${var.cluster}"
}

provider "helm" {
  alias = "staging"
  namespace = "${module.staging_namespace.name}"
  tiller_image = "gcr.io/kubernetes-helm/tiller:v2.14.1"
  service_account = "${module.staging_namespace.tiller_service_account}"

  kubernetes {
    config_context = "${var.cluster}"
  }
}
module "staging_namespace" {
  source     = "../../modules/common/namespace"
  namespace  = "${var.product_name}-staging"
  issuer_type = "selfSigned"
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
