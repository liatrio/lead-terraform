
terraform {
  required_version = ">= 0.12"
  required_providers {
    external = {
      source = "hashicorp/external"
    }
    harbor = {
      source = "liatrio/harbor"
      # TF-UPGRADE-TODO
      #
      # No source detected for this provider. You must add a source address
      # in the following format:
      #
      # source = "your-registry.example.com/organization/harbor"
      #
      # For more information, see the provider source documentation:
      #
      # https://www.terraform.io/docs/configuration/providers.html#provider-source
      version = "= 0.2.0-pre"
    }
    helm = {
      source = "hashicorp/helm"
    }
    keycloak = {
      source = "mrparkers/keycloak"
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
