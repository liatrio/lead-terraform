
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

resource "kubernetes_pod" "nginx" {
  provider = "kubernetes.production"

  metadata {
    name = "nginx"
    namespace = module.product_base.production_namespace
  }
  spec {
    container {
      name = "nginx"
      image = "nginx:latest"
    }
  }
}
