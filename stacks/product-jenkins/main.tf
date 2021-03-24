terraform {
  backend "s3" {}
}

provider "kubernetes" {
  alias          = "toolchain"
  config_context = var.config_context
}

provider "helm" {
  alias = "toolchain"


  kubernetes {
    config_context = var.config_context
  }
}

provider "kubernetes" {
  alias          = "staging"
  config_context = var.config_context
}

provider "helm" {
  alias = "staging"

  kubernetes {
    config_context = var.config_context
  }
}

provider "kubernetes" {
  alias          = "production"
  config_context = var.config_context
}

provider "helm" {
  alias = "production"

  kubernetes {
    config_context = var.config_context
  }
}

provider "kubernetes" {
  alias          = "system"
  config_context = var.config_context
}

provider "helm" {
  alias = "system"

  kubernetes {
    config_context = var.config_context
  }
}

module "product_jenkins" {
  source                  = "../../modules/lead/product-jenkins"
  cluster_domain          = var.cluster_domain
  product_name            = var.product_name
  image_whitelist         = var.image_whitelist
  enable_keycloak         = var.enable_keycloak
  enable_istio            = var.enable_istio
  enable_harbor           = var.enable_harbor
  enable_artifactory_jcr  = var.enable_artifactory_jcr
  builder_images_version  = var.builder_images_version
  jenkins_image_version   = var.jenkins_image_version
  toolchain_image_repo    = var.toolchain_image_repo
  product_image_repo      = var.product_image_repo
  pipelines               = var.pipelines
  vault_namespace         = var.vault_namespace
  vault_root_token_secret = var.vault_root_token_secret

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
