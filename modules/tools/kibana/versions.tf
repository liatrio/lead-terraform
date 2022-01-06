terraform {
  required_version = ">= 0.13"
  required_providers {
    external = {
      source = "hashicorp/external"
    }
    helm = {
      source = "hashicorp/helm"
    }
    keycloak = {
      source  = "mrparkers/keycloak"
      version = ">= 3.3.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    null = {
      source = "hashicorp/null"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}
