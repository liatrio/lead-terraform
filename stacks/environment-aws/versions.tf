terraform {
  required_version = ">= 0.12"
  required_providers {
    external = {
      source = "hashicorp/external"
    }
    harbor = {
      source = "liatrio/harbor"
      version = "= 0.2.0-pre"
    }
    helm = {
      source = "hashicorp/helm"
    }
    keycloak = {
      source = "mrparkers/keycloak"
      version = "= 2.0.0-rc.0"
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
    template = {
      source = "hashicorp/template"
    }
  }
}
