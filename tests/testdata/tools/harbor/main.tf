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

module "harbor" {
  source                       = "../../../../modules/tools/harbor"
  namespace                    = var.namespace
  admin_password               = var.admin_password
  harbor_registry_disk_size    = "10Mi"
  harbor_chartmuseum_disk_size = "10Mi"
  harbor_database_disk_size    = "10Mi"
  k8s_storage_class            = var.k8s_storage_class
  issuer_kind                  = var.issuer_kind
  issuer_name                  = var.issuer_name
  protect_pvc_resources        = false
  harbor_ingress_hostname      = "harbor.tests.lead-terraform.liatr.io"
  notary_ingress_hostname      = "notary.tests.lead-terraform.liatr.io"
}
