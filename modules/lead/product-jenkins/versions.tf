
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
      # TF-UPGRADE-TODO
      #
      # No source detected for this provider. You must add a source address
      # in the following format:
      #
      # source = "your-registry.example.com/organization/keycloak"
      #
      # For more information, see the provider source documentation:
      #
      # https://www.terraform.io/docs/configuration/providers.html#provider-source
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
