terraform {
  backend "artifactory" {}
}

provider "kubernetes" {
  alias            = "toolchain"
  load_config_file = var.load_config_file
  config_context   = var.config_context
}

provider "helm" {
  alias           = "toolchain"
  namespace       = module.product.toolchain_namespace
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.14.1"
  service_account = module.product.toolchain_service_account

  kubernetes {
    load_config_file = var.load_config_file
    config_context   = var.config_context
  }
}

provider "kubernetes" {
  alias            = "staging"
  load_config_file = var.load_config_file
  config_context   = var.config_context
}

provider "helm" {
  alias           = "staging"
  namespace       = module.product.staging_namespace
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.14.1"
  service_account = module.product.staging_service_account

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
  namespace       = module.product.production_namespace
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.14.1"
  service_account = module.product.production_service_account

  kubernetes {
    load_config_file = var.load_config_file
    config_context   = var.config_context
  }
}

provider "kubernetes" {
  alias            = "system"
  load_config_file = var.load_config_file
  config_context   = var.config_context
}

provider "helm" {
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
  image_whitelist         = var.image_whitelist
  ingress_controller_type = var.ingress_controller_type

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
