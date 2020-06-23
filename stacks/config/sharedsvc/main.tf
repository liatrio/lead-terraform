terraform {
  backend "s3" {
  }
}

provider "vault" {
  address = var.vault_address
}
