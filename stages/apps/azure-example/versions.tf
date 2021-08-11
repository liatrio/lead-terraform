terraform {
  required_version = ">= 0.13"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.20.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "1.1.1"
    }
  }
}