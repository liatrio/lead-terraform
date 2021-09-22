terraform {
  backend "s3" {
  }
}

provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

provider "vault" {
  address = var.vault_address

  // before the `vault_aws_auth_backend_role.vault_admin` resource is created, the `auth_login` block below must be
  // commented out. if the `auth_login` block is commented out, the root vault token must be used instead to authenticate
  auth_login {
    path   = "auth/aws/login"
    method = "aws"

    parameters = {
      role = var.vault_role
    }
  }
}
