terraform {
  required_version = ">= 0.13"
  required_providers {
    helm = {
      source = "hashicorp/helm"
    }
    keycloak = {
      source = "mrparkers/keycloak"
      version = "= 2.0.0-rc.0"
    }
  }
}
