terraform {
  required_version = ">= 0.13"
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "1.1.1"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

provider "kubernetes" {
  config_path = var.kube_config_path
}

provider "helm" {
  kubernetes {
    config_path = var.kube_config_path
  }
}

module "ingress" {
  source                         = "../../../../modules/lead/toolchain-ingress"
  namespace                      = var.namespace
  issuer_kind                    = var.issuer_kind
  issuer_name                    = var.issuer_name
  cluster_domain                 = var.cluster_domain
  ingress_controller_type        = var.ingress_controller_type
  internal_ingress_source_ranges = var.service_load_balancer_source_ranges
}
