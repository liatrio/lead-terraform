terraform {
  backend "local" {}
}

provider "kubernetes" {
  alias            = "toolchain"
  load_config_file = var.load_config_file
  config_context   = var.config_context
}

provider "helm" {
  version         = "0.10.4"
  alias           = "toolchain"
  namespace       = module.product.toolchain_namespace
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.15.1"
  service_account = module.product.toolchain_service_account

  kubernetes {
    load_config_file = var.load_config_file
    config_context   = var.config_context
  }

  override = [
    "spec.template.spec.containers[0].resources.limits.memory=128Mi",
    "spec.template.spec.containers[0].resources.requests.memory=64Mi",
    "spec.template.spec.containers[0].resources.limits.cpu=200m",
    "spec.template.spec.containers[0].resources.requests.cpu=50m",
  ]
}

provider "kubernetes" {
  alias            = "staging"
  load_config_file = var.load_config_file
  config_context   = var.config_context
}

provider "helm" {
  version         = "0.10.4"
  alias           = "staging"
  namespace       = module.product.staging_namespace
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.15.1"
  service_account = module.product.staging_service_account

  kubernetes {
    load_config_file = var.load_config_file
    config_context   = var.config_context
  }

  override = [
    "spec.template.spec.containers[0].resources.limits.memory=128Mi",
    "spec.template.spec.containers[0].resources.requests.memory=64Mi",
    "spec.template.spec.containers[0].resources.limits.cpu=200m",
    "spec.template.spec.containers[0].resources.requests.cpu=50m",
  ]
}

provider "kubernetes" {
  alias            = "production"
  load_config_file = var.load_config_file
  config_context   = var.config_context
}

provider "helm" {
  version         = "0.10.4"
  alias           = "production"
  namespace       = module.product.production_namespace
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.15.1"
  service_account = module.product.production_service_account

  kubernetes {
    load_config_file = var.load_config_file
    config_context   = var.config_context
  }

  override = [
    "spec.template.spec.containers[0].resources.limits.memory=128Mi",
    "spec.template.spec.containers[0].resources.requests.memory=64Mi",
    "spec.template.spec.containers[0].resources.limits.cpu=200m",
    "spec.template.spec.containers[0].resources.requests.cpu=50m",
  ]
}

provider "kubernetes" {
  alias            = "system"
  load_config_file = var.load_config_file
  config_context   = var.config_context
}

provider "helm" {
  version         = "0.10.4"
  alias           = "system"
  namespace       = "lead-system"
  install_tiller  = false

  kubernetes {
    load_config_file = var.load_config_file
    config_context   = var.config_context
  }
}

module "product" {
  source                  = "../../modules/lead/product"
  cluster_domain          = var.cluster_domain
  product_name            = var.product_name
  issuer_type             = var.issuer_type
  issuer_server           = var.issuer_server
  image_whitelist         = var.image_whitelist
  ingress_controller_type = var.ingress_controller_type
  enable_keycloak         = var.enable_keycloak
  enable_istio            = var.enable_istio
  builder_images_version  = var.builder_images_version
  jenkins_image_version   = var.jenkins_image_version
  image_repo              = var.image_repo

  providers = {
    kubernetes.toolchain  = kubernetes.toolchain
    helm.toolchain        = helm.toolchain
    kubernetes.staging    = kubernetes.staging
    helm.staging          = helm.staging
    kubernetes.production = kubernetes.production
    helm.production       = helm.production
    kubernetes.system     = kubernetes.system
    helm.system           = helm.system
  }
}
