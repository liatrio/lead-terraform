terraform {
  required_version = ">= 0.13"
  required_providers {
    keycloak = {
      source  = "mrparkers/keycloak"
      version = "3.5.1"
    }
    sonarqube = {
      source  = "jdamata/sonarqube"
      version = "0.15.5"
    }
    harbor = {
      source  = "BESTSELLER/harbor"
      version = "3.4.5"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.8.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0.1"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "2.24.0"
    }
  }
}
