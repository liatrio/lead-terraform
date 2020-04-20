terraform {
  backend "s3" {
  }
}

provider "aws" {
  version = ">= 2.29.0"
  region  = var.region
}
