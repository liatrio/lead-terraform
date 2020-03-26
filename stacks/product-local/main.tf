terraform {
  backend "local" {}
}

provider "kubernetes" {
  alias            = "toolchain"
  load_config_file = var.load_config_file
  config_context   = var.config_context
}

provider "helm" {
  alias           = "toolchain"
  version         = "1.0.0"

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
  version         = "1.0.0"

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
  version         = "1.0.0"

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
  version         = "1.0.0"
  alias           = "system"

  kubernetes {
    load_config_file = var.load_config_file
    config_context   = var.config_context
  }
}

module "product_jenkins" {
  source                  = "../../modules/lead/product-jenkins"
  cluster_domain          = var.cluster_domain
  product_name            = var.product_name
  image_whitelist         = var.image_whitelist
  enable_keycloak         = var.enable_keycloak
  enable_istio            = var.enable_istio
  builder_images_version  = var.builder_images_version
  jenkins_image_version   = var.jenkins_image_version
  toolchain_image_repo    = var.toolchain_image_repo
  product_image_repo      = var.product_image_repo
  pipelines               = var.pipelines

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