terraform {
  backend "local" {}
}

provider "kubernetes" {
  alias            = "toolchain"
  load_config_file = var.load_config_file
  config_context   = var.config_context
}

provider "helm" {
  version         = "1.1.0"
  alias           = "toolchain"

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
  version         = "1.1.0"
  alias           = "staging"

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
  version         = "1.1.0"
  alias           = "production"

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
  version         = "1.1.0"
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
