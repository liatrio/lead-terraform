
terraform {
  required_version = ">= 0.13"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "= 2.0.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.0.2"
    }
  }
}
