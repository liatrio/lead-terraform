
terraform {
  required_version = ">= 0.13"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "= 2.0.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.0.3"
    }

    harbor = {
      source  = "liatrio/harbor"
      version = "0.4.0"
    }

    keycloak = {
      source  = "mrparkers/keycloak"
      version = "3.5.1"
    }

    template = {
      source = "hashicorp/template"
    }
  }
}
