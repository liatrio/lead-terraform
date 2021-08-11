resource "vault_mount" "gpg" {
  path = "/gpg"
  type = "kv"

  options = {
    version = "2"
  }
}

resource "vault_policy" "gpg_aws_admin" {
  name   = "gpg-aws-admin"
  policy = file("${path.module}/vault-policies/gpg-aws-admin.hcl")
}
