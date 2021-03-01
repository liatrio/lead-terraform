terraform {
  required_version = ">= 0.13.1"
  required_providers {
    harbor = {
      source = "liatrio/harbor"
      version = "0.3.2"
    }
    keycloak = {
      source = "mrparkers/keycloak"
      version = "2.0.0-rc.0"
    }
    helm = {
      source = "hashicorp/helm"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}