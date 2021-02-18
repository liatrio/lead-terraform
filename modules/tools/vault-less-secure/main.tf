resource "helm_release" "vault" {
  chart      = "vault"
  name       = "vault"
  namespace  = var.namespace
  repository = "https://helm.releases.hashicorp.com"
  version    = "0.6.0"
  wait       = true

  values = [
    templatefile("${path.module}/values.tpl", {
      vault_hostname = var.vault_hostname
      vault_version  = "1.4.2"
      vault_config   = indent(6, templatefile("${path.module}/vault-config.hcl.tpl", {
        region                = var.region
        aws_access_key_id     = var.vault_aws_access_key_id
        aws_secret_access_key = var.vault_aws_secret_access_key
        dynamodb_table_name   = var.vault_dynamodb_table_name
        kms_key_id            = var.vault_kms_key_id
      }))
    })
  ]
}

module "vault_operator_init" {
  source = "matti/resource/shell"

  command = "kubectl exec -it -n ${var.namespace} vault-0 -- vault operator init -format=json | jq -rc '.root_token'"
  depends = [
    helm_release.vault.id
  ]
}

resource "kubernetes_secret" "vault_root_token" {
  metadata {
    namespace = var.namespace
    name      = "vault-root-token"
  }

  data = {
    token = module.vault_operator_init.stdout
  }

  lifecycle {
    ignore_changes = [data]
  }
}
