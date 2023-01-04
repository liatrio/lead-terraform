terraform {
  required_version = ">= 0.13"
  required_providers {
    keycloak = {
      source  = "mrparkers/keycloak"
      version = "3.5.1"
    }
    sonarqube = {
      source  = "jdamata/sonarqube"
      version = "0.0.7"
    }
    harbor = {
      source  = "BESTSELLER/harbor"
      version = "3.4.5"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "1.3.0"
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
