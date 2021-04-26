terraform {
  required_version = ">= 0.13"
  required_providers {
    external = {
      source = "hashicorp/external"
      version = "~> 2.0.0"
    }
    harbor = {
      source = "liatrio/harbor"
      version = "= 0.3.3"
    }
    artifactory = {
      source  = "jfrog/artifactory"
      version = "~> 2.2.5"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.0.1"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.0.3"
    }
    keycloak = {
      source = "mrparkers/keycloak"
      version = "= 2.0.0-rc.0"
    }
    template = {
      source = "hashicorp/template"
      version = "~> 2.2.0"
    }
    null = {
      source = "hashicorp/null"
      version = "~> 3.0.0"
    }
    random = {
      source = "hashicorp/random"
      version = "~> 3.0.1"
    }
    vault = {
      source = "hashicorp/vault"
      version = "~> 2.18.0"
    }
    aws = {
      source = "hashicorp/aws"
        version = "2.53"
    }
  }
}
