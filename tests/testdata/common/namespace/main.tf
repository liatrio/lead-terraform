terraform {
  required_version = ">= 0.13"
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

provider "kubernetes" {
  config_path = var.kube_config_path
}

module "namespace" {
  source    = "../../../../modules/common/namespace"
  namespace = var.namespace
}
