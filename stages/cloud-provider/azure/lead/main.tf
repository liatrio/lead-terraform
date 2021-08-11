terraform {
  required_version = ">=0.13"
}

provider "azurerm" {
  features {}
}

terraform {
  required_version = ">= 0.13"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.20.0"
    }
  }
}