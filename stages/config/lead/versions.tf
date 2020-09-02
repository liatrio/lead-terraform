terraform {
  required_version = ">= 0.13"
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
    template = {
      source = "hashicorp/template"
    }
  }
}
