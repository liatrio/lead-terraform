module "vault_tls_certificate" {
  source = "../../common/certificates"

  name      = "vault-tls"
  namespace = var.namespace
  domain    = var.vault_hostname
  enabled   = true

  issuer_name = var.cert_issuer_name
  issuer_kind = var.cert_issuer_kind
}

resource "helm_release" "vault" {
  chart     = "${path.module}/charts/vault-helm"
  name      = "vault"
  namespace = var.namespace
  wait      = true

  values = [
    templatefile("${path.module}/values.tpl", {
      vault_tls_secret   = module.vault_tls_certificate.cert_secret_name
      vault_hostname     = var.vault_hostname
      vault_iam_role_arn = var.vault_iam_role_arn
      vault_version      = "1.4.2"
      vault_config       = indent(6, templatefile("${path.module}/vault-config.hcl.tpl", {
        region                = var.region
        aws_access_key_id     = var.vault_aws_access_key_id
        aws_secret_access_key = var.vault_aws_secret_access_key
        dynamodb_table_name   = var.vault_dynamodb_table_name
        kms_key_id            = var.vault_kms_key_id
      }))
    })
  ]
}
