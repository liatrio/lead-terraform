terraform {
  required_version = ">= 0.13"
  required_providers {
    external = {
      source  = "hashicorp/external"
      version = "~> 2.2.0"
    }
    harbor = {
      source = "BESTSELLER/harbor"
      version = "3.4.5"
    }
    artifactory = {
      source  = "jfrog/artifactory"
      version = "~> 2.2.5"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.0.3"
    }
    keycloak = {
      source  = "mrparkers/keycloak"
      version = "3.5.1"
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
      version = ">= 2.24.0"
    }
  }
}
