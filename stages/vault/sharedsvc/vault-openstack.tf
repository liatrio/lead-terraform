resource "vault_mount" "openstack" {
  path = "/openstack"
  type = "kv"

  options = {
    version = "2"
  }
}

resource "vault_policy" "openstack_aws_admin" {
  name   = "openstack-aws-admin"
  policy = file("${path.module}/vault-policies/openstack-aws-admin.hcl")
}
