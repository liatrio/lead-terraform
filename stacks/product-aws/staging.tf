provider "kubernetes" {
  alias = "staging"
  load_config_file = false
}

provider "helm" {
  alias = "staging"
  namespace = "${module.staging_namespace.name}"
  tiller_image = "gcr.io/kubernetes-helm/tiller:v2.14.0"
  service_account = "${module.staging_namespace.tiller_service_account}"

  kubernetes {
    load_config_file = false
  }
}
module "staging_namespace" {
  source     = "../../modules/common/namespace"
  namespace  = "${var.product_name}-staging"
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