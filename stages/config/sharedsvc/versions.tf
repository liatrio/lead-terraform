terraform {
  required_version = ">= 0.13"
  required_providers {
    keycloak = {
      source = "mrparkers/keycloak"
      version = "= 3.3.0"
    }
  }
}
