terraform {
  required_version = ">= 0.13.1"
  required_providers {
    harbor = {
      source  = "liatrio/harbor"
      version = "0.4.0"
    }
    keycloak = {
      source  = "mrparkers/keycloak"
      version = "3.3.0"
    }
    helm = {
      source = "hashicorp/helm"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}
