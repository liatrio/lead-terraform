resource "vault_mount" "lead" {
  path = "/lead"
  type = "kv"

  options = {
    version = "2"
  }
}

resource "vault_policy" "lead_aws_admin" {
  name = "lead-aws-admin"
  policy = templatefile("${path.module}/vault-policies/lead-aws-admin.hcl", {
    mount_accessor = vault_auth_backend.aws.accessor
  })
}

resource "vault_policy" "lead_aws_developer" {
  name = "lead-aws-developer"
  policy = templatefile("${path.module}/vault-policies/lead-aws-developer.hcl", {
    mount_accessor = vault_auth_backend.aws.accessor
  })
}
