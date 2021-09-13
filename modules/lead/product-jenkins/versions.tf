
terraform {
  required_version = ">= 0.13"
  required_providers {
    harbor = {
      source  = "liatrio/harbor"
      version = "= 0.4.0"
    }
    helm = {
      source = "hashicorp/helm"
    }
    keycloak = {
      source  = "mrparkers/keycloak"
      version = "3.3.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    random = {
      source = "hashicorp/random"
    }
    template = {
      source = "hashicorp/template"
    }
  }
}
