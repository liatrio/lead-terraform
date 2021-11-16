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

module "keycloak" {
  source = "../../../../modules/tools/keycloak"

  namespace               = var.namespace
  cluster_domain          = "${var.cluster}.${var.root_zone_name}"
  postgres_password       = var.postgres_password
  keycloak_admin_password = var.keycloak_admin_password
}
