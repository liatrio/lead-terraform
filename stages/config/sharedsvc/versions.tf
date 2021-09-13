terraform {
  required_version = ">= 0.13"
  required_providers {
    keycloak = {
      source  = "mrparkers/keycloak"
      version = "3.3.0"
    }
    sonarqube = {
      source  = "jdamata/sonarqube"
      version = "0.0.7"
    }
    harbor = {
      source  = "liatrio/harbor"
      version = "0.4.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "1.3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0.1"
    }
  }
}
