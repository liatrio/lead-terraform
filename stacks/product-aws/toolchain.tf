provider "kubernetes" {
  alias = "toolchain"
  load_config_file = false
}

provider "helm" {
  alias = "toolchain"
  namespace = "${module.toolchain_namespace.name}"
  tiller_image = "gcr.io/kubernetes-helm/tiller:v2.14.0"
  service_account = "${module.toolchain_namespace.tiller_service_account}"

  kubernetes {
    load_config_file = false
  }
}

module "toolchain_namespace" {
  source     = "../../modules/common/namespace"
  namespace  = "${var.product_name}-toolchain"
  annotations {
    name  = "${var.product_name}-toolchain"
    cluster = "${var.cluster}"
    "opa.lead.liatrio/ingress-whitelist" = "*.${var.product_name}-toolchain.${var.cluster}.${var.root_zone_name}"
    "opa.lead.liatrio/image-whitelist" = "${var.image_whitelist}"
  }
}

module "product" {
  source             = "../../modules/lead/product"
  root_zone_name     = "${var.root_zone_name}"
  cluster            = "${var.cluster}"
  namespace          = "${var.product_name}-toolchain"
}