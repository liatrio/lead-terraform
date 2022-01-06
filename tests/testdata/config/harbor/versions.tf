terraform {
  required_version = ">= 0.13.1"
  required_providers {
    harbor = {
      source  = "liatrio/harbor"
      version = "0.5.0"
    }
    keycloak = {
      source  = "mrparkers/keycloak"
      version = "3.5.1"
    }
    helm = {
      source = "hashicorp/helm"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}
