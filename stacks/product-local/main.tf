terraform {
  backend "local" {}
}
provider "kubernetes" {
  alias = "toolchain"
  config_context = "${var.cluster}"
}

provider "helm" {
  alias = "toolchain"
  namespace = "${module.product.toolchain_namespace}"
  tiller_image = "gcr.io/kubernetes-helm/tiller:v2.14.1"
  service_account = "${module.product.toolchain_service_account}"

  kubernetes {
    config_context = "${var.cluster}"
  }
}
provider "kubernetes" {
  alias = "staging"
  config_context = "${var.cluster}"
}

provider "helm" {
  alias = "staging"
  namespace = "${module.product.staging_namespace}"
  tiller_image = "gcr.io/kubernetes-helm/tiller:v2.14.1"
  service_account = "${module.product.staging_service_account}"

  kubernetes {
    config_context = "${var.cluster}"
  }
}
provider "kubernetes" {
  alias = "production"
  config_context = "${var.cluster}"
}

provider "helm" {
  alias = "production"
  namespace = "${module.product.production_namespace}"
  tiller_image = "gcr.io/kubernetes-helm/tiller:v2.14.1"
  service_account = "${module.product.production_service_account}"

  kubernetes {
    config_context = "${var.cluster}"
  }
}


module "product" {
  source             = "../../modules/lead/product"
  root_zone_name     = "${var.root_zone_name}"
  cluster            = "${var.cluster}"
  product_name       = "${var.product_name}"
  issuer_type        = "selfSigned"
  image_whitelist    = "${var.image_whitelist}"
  ingress_controller_type = "NodePort"

  providers {
    "kubernetes.toolchain"  = "kubernetes.toolchain"
    "helm.toolchain"        = "helm.toolchain"
    "kubernetes.staging"    = "kubernetes.staging"
    "helm.staging"          = "helm.staging"
    "kubernetes.production" = "kubernetes.production"
    "helm.production"       = "helm.production"
  }
}