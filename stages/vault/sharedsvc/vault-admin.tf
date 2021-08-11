resource "vault_policy" "vault_admin" {
  name   = "vault-admin"
  policy = file("${path.module}/vault-policies/vault-admin.hcl")
}
