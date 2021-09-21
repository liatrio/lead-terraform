terraform {
  required_version = ">= 0.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.3.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "1.3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0.1"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0.1"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = ">= 2.24.0"
    }
  }
}
