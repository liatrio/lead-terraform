terraform {
  backend "s3" {
  }
}

data "aws_caller_identity" "current" {}

provider "vault" {
  address = var.vault_address

  // before the `vault_aws_auth_backend_role.vault_admin` resource is created, the `auth_login` block below must be
  // commented out. if the `auth_login` block is commented out, the root vault token must be used instead to authenticate
  auth_login {
    path = "auth/aws/login"

    parameters = {
      role                    = "vault-admin"
      iam_http_request_method = "POST"
      iam_request_url         = base64encode("https://sts.amazonaws.com/")
      iam_request_body        = base64encode("Action=GetCallerIdentity&Version=2011-06-15")
      iam_request_headers     = var.iam_caller_identity_headers
    }
  }
}

provider "vault" {
  alias = "main"
  address = var.vault_address

  // before the `vault_aws_auth_backend_role.vault_admin` resource is created, the `auth_login` block below must be
  // commented out. if the `auth_login` block is commented out, the root vault token must be used instead to authenticate
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
  url            = "https://${var.keycloak_hostname}"
  initial_login  = false
  client_timeout = 15
}
