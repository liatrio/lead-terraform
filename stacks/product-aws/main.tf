
terraform {
  backend "s3" {}
}

provider "kubernetes" {
  alias            = "staging"
  load_config_file = var.load_config_file
  config_context   = var.config_context
}

provider "aws" {
  version = ">= 2.29.0"
  region  = var.region
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

module "product-aws" {
  source                  = "../../modules/lead/product-aws"
  cluster_domain          = var.cluster_domain
  product_name            = var.product_name
  image_whitelist         = var.image_whitelist
  providers = {
    kubernetes.staging    = kubernetes.staging
    helm.staging          = helm.staging
    kubernetes.production = kubernetes.production
    helm.production       = helm.production
    aws                   = aws
  }
}
