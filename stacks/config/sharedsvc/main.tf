terraform {
  backend "s3" {
  }
}

provider "vault" {
  address = var.vault_address
}

resource "vault_mount" "example" {
  path        = "dummy"
  type        = "generic"
  description = "This is an example mount"
}
