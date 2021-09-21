terraform {
  required_version = ">= 0.13"
  required_providers {
    keycloak = {
      source  = "mrparkers/keycloak"
      version = "= 3.3.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = ">= 2.24.0"
    }
  }
}
