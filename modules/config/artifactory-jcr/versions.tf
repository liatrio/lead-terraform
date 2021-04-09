terraform {
  required_version = ">= 0.13.1"
  required_providers {
    helm = {
      source = "hashicorp/helm"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    artifactory = {
      source  = "registry.terraform.io/jfrog/artifactory"
    }
  }
}