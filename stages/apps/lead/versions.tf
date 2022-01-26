terraform {
  required_version = ">= 0.13"
  required_providers {
    external = {
      source  = "hashicorp/external"
      version = "~> 2.2.0"
    }
    harbor = {
      source  = "BESTSELLER/harbor"
      version = "3.4.5"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.3.0"
    }
    keycloak = {
      source  = "mrparkers/keycloak"
      version = "3.5.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.4.1"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "2.24.0"
    }
  }
}
