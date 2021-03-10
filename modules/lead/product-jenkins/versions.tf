
terraform {
  required_version = ">= 0.13"
  required_providers {
    harbor = {
      source  = "liatrio/harbor"
      version = "= 0.3.3"
    }
    helm = {
      source = "hashicorp/helm"
    }
    keycloak = {
      source = "mrparkers/keycloak"
      version = "= 2.3.0"
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
