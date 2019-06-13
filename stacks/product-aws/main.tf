terraform {
  backend "local" {}
}
provider "kubernetes" {
  alias = "toolchain"
  load_config_file = false
}

provider "helm" {
  alias = "toolchain"
  namespace = "${module.product.toolchain_namespace}"
  tiller_image = "gcr.io/kubernetes-helm/tiller:v2.14.1"
  service_account = "${module.product.toolchain_service_account}"

  kubernetes {
    load_config_file = false
  }
}
provider "kubernetes" {
  alias = "staging"
  load_config_file = false
}

provider "helm" {
  alias = "staging"
  namespace = "${module.product.staging_namespace}"
  tiller_image = "gcr.io/kubernetes-helm/tiller:v2.14.1"
  service_account = "${module.product.staging_service_account}"

  kubernetes {
    load_config_file = false
  }
}
provider "kubernetes" {
  alias = "production"
  load_config_file = false
}

provider "helm" {
  alias = "production"
  namespace = "${module.product.production_namespace}"
  tiller_image = "gcr.io/kubernetes-helm/tiller:v2.14.1"
  service_account = "${module.product.production_service_account}"

  kubernetes {
    load_config_file = false
  }
}


module "product" {
  source             = "../../modules/lead/product"
  root_zone_name     = "${var.root_zone_name}"
  cluster            = "${var.cluster}"
  product_name       = "${var.product_name}"
  issuer_type        = "acme"
  image_whitelist    = "${var.image_whitelist}"
  ingress_controller_type = "LoadBalancer"

  providers {
    "kubernetes.toolchain"  = "kubernetes.toolchain"
    "helm.toolchain"        = "helm.toolchain"
    "kubernetes.staging"    = "kubernetes.staging"
    "helm.staging"          = "helm.staging"
    "kubernetes.production" = "kubernetes.production"
    "helm.production"       = "helm.production"
  }
}