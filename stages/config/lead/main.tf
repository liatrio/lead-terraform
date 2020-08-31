terraform {
  backend "s3" {
  }
}

provider "aws" {
  version = "2.53"
  region  = var.region
}

data "aws_caller_identity" "current" {}

provider "vault" {
  address = var.vault_address

  auth_login {
    path = "auth/aws/login"

    parameters = {
      role                    = "aws-admin"
      iam_http_request_method = "POST"
      iam_request_url         = base64encode("https://sts.amazonaws.com/")
      iam_request_body        = base64encode("Action=GetCallerIdentity&Version=2011-06-15")
      iam_request_headers     = var.iam_caller_identity_headers
    }
  }
}

provider "keycloak" {
  client_id      = "admin-cli"
  username       = "keycloak"
  password       = data.vault_generic_secret.keycloak.data["admin-password"]
  url            = var.keycloak_hostname
  initial_login  = false
  client_timeout = 15
}

