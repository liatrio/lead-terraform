
terraform {
  required_version = ">= 0.13"
  required_providers {
    harbor = {
      source = "BESTSELLER/harbor"
      version = "3.4.5"
    }
    helm = {
      source = "hashicorp/helm"
    }
    keycloak = {
      source  = "mrparkers/keycloak"
      version = "3.5.1"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}
