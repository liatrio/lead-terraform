// aws authentication / roles

locals {
  aws_accounts = [
    "489130170427", // prod
    "774051255656"  // sandbox
  ]
}

resource "vault_auth_backend" "aws" {
  type = "aws"
}

resource "vault_aws_auth_backend_role" "vault_admin" {
  backend                         = vault_auth_backend.aws.path
  role                            = "vault-admin"
  auth_type                       = "iam"
  bound_iam_principal_arns        = [
    "arn:aws:iam::265560927720:role/VaultAdministrator"
  ]
  resolve_aws_unique_ids = false
  token_policies = [
    vault_policy.vault_admin.name
  ]
}

resource "vault_aws_auth_backend_role" "aws_admin" {
  backend                         = vault_auth_backend.aws.path
  role                            = "aws-admin"
  auth_type                       = "iam"
  bound_iam_principal_arns        = formatlist("arn:aws:iam::%s:role/Administrator", local.aws_accounts)
  resolve_aws_unique_ids = false
  token_policies = [
    vault_policy.lead_aws_admin.name
  ]
}

resource "vault_aws_auth_backend_role" "aws_developer" {
  backend                         = vault_auth_backend.aws.path
  role                            = "aws-developer"
  auth_type                       = "iam"
  bound_iam_principal_arns        = formatlist("arn:aws:iam::%s:role/Developer", local.aws_accounts)
  resolve_aws_unique_ids = false
  token_policies = [
    vault_policy.lead_aws_developer.name
  ]
}
