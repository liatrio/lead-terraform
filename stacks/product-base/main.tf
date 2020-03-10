
terraform {
  backend "local" {}
}

provider "kubernetes" {
  alias            = "staging"
  load_config_file = var.load_config_file
  config_context   = var.config_context
}

provider "helm" {
  alias           = "staging"
  version         = "0.10.4"
  namespace       = module.product_base.staging_namespace
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.15.1"
  service_account = module.product_base.staging_service_account

  override = [
    "spec.template.spec.containers[0].resources.limits.memory=128Mi",
    "spec.template.spec.containers[0].resources.requests.memory=64Mi",
    "spec.template.spec.containers[0].resources.limits.cpu=200m",
    "spec.template.spec.containers[0].resources.requests.cpu=50m",
  ]

  kubernetes {
    load_config_file = var.load_config_file
    config_context   = var.config_context
  }
}

provider "kubernetes" {
  alias            = "production"
  load_config_file = var.load_config_file
  config_context   = var.config_context
}

provider "helm" {
  alias           = "production"
  version         = "0.10.4"
  namespace       = module.product_base.production_namespace
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.15.1"
  service_account = module.product_base.production_service_account

  override = [
    "spec.template.spec.containers[0].resources.limits.memory=128Mi",
    "spec.template.spec.containers[0].resources.requests.memory=64Mi",
    "spec.template.spec.containers[0].resources.limits.cpu=200m",
    "spec.template.spec.containers[0].resources.requests.cpu=50m",
  ]

  kubernetes {
    load_config_file = var.load_config_file
    config_context   = var.config_context
  }
}

module "product_base" {
  source                  = "../../modules/lead/product-base"

  providers = {
    kubernetes.staging    = kubernetes.staging
    helm.staging          = helm.staging
    kubernetes.production = kubernetes.production
    helm.production       = helm.production
  }

  cluster_domain  = var.cluster_domain
  image_whitelist = var.image_whitelist
  product_name    = var.product_name
}
