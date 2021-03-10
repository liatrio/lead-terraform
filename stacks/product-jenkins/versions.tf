
terraform {
  required_version = ">= 0.13"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "= 2.0.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.0.2"
    }

    harbor = {
      source  = "liatrio/harbor"
      version = "= 0.3.3"
    }

    keycloak = {
      source  = "mrparkers/keycloak"
      version = "= 2.3.0"
    }

    template = {
      source  = "hashicorp/template"
    }
  }
}
