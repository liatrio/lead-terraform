// aws authentication / roles

locals {
  prod_aws_account       = "489130170427"
  non_prod_aws_account   = "281127131043"
  sandbox_aws_account    = "774051255656"
  sharedsvc_aws_account  = "265560927720"
  remote_k8s_aws_account = "210831435012"
  rtx_aws_account        = "702109968614"

  vault_token_ttl_thirty_minutes = 60 * 30
}

resource "vault_auth_backend" "aws" {
  type = "aws"
}

resource "vault_aws_auth_backend_role" "vault_admin" {
  backend   = vault_auth_backend.aws.path
  role      = "vault-admin"
  auth_type = "iam"
  bound_iam_principal_arns = [
    "arn:aws:iam::${local.sharedsvc_aws_account}:role/VaultAdministrator"
  ]
  resolve_aws_unique_ids = false
  token_policies = [
    vault_policy.vault_admin.name
  ]

  token_ttl     = local.vault_token_ttl_thirty_minutes
  token_max_ttl = local.vault_token_ttl_thirty_minutes
}

resource "vault_aws_auth_backend_role" "gpg_aws_admin" {
  backend   = vault_auth_backend.aws.path
  role      = "gpg-aws-admin"
  auth_type = "iam"
  bound_iam_principal_arns = [
    "arn:aws:iam::${local.prod_aws_account}:role/Administrator"
  ]
  resolve_aws_unique_ids = false
  token_policies = [
    vault_policy.gpg_aws_admin.name
  ]

  token_ttl     = local.vault_token_ttl_thirty_minutes
  token_max_ttl = local.vault_token_ttl_thirty_minutes
}

resource "vault_aws_auth_backend_role" "aws_admin" {
  backend   = vault_auth_backend.aws.path
  role      = "aws-admin"
  auth_type = "iam"
  bound_iam_principal_arns = formatlist("arn:aws:iam::%s:role/Administrator", [
    local.prod_aws_account,
    local.non_prod_aws_account,
    local.sandbox_aws_account,
    local.remote_k8s_aws_account,
    local.rtx_aws_account,
    local.sharedsvc_aws_account,
  ])
  resolve_aws_unique_ids = false
  token_policies = [
    vault_policy.lead_aws_admin.name,
    vault_policy.openstack_aws_admin.name
  ]

  token_ttl     = local.vault_token_ttl_thirty_minutes
  token_max_ttl = local.vault_token_ttl_thirty_minutes
}

resource "vault_aws_auth_backend_role" "aws_developer" {
  backend   = vault_auth_backend.aws.path
  role      = "aws-developer"
  auth_type = "iam"
  bound_iam_principal_arns = formatlist("arn:aws:iam::%s:role/Developer", [
    local.prod_aws_account,
    local.non_prod_aws_account,
    local.sandbox_aws_account,
    local.remote_k8s_aws_account,
    local.rtx_aws_account,
    local.sharedsvc_aws_account,
  ])
  resolve_aws_unique_ids = false
  token_policies = [
    vault_policy.lead_aws_developer.name
  ]

  token_ttl     = local.vault_token_ttl_thirty_minutes
  token_max_ttl = local.vault_token_ttl_thirty_minutes
}
