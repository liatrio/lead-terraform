
terraform {
  required_version = ">= 0.12"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "2.53"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "1.1.1"
    }
  }
}
