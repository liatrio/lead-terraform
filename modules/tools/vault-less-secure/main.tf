locals {
  vault_secret_name = "vault-credentials"
}

resource "kubernetes_service_account" "vault" {
  metadata {
    name      = "vault"
    namespace = var.namespace

    annotations = {
      "eks.amazonaws.com/role-arn" : var.vault_service_account_arn
    }
  }
}

resource "kubernetes_role" "vault" {
  metadata {
    name      = "vault-credentials-manager"
    namespace = var.namespace
  }
  rule {
    api_groups     = [""]
    resources      = ["secrets"]
    verbs          = ["*"]
    resource_names = [local.vault_secret_name]
  }
  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["create"]
  }
}

resource "kubernetes_role_binding" "vault" {
  metadata {
    name      = "vault-credentials-manager"
    namespace = var.namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.vault.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.vault.metadata[0].name
    namespace = var.namespace
  }
}

resource "helm_release" "vault" {
  chart      = "vault"
  name       = "vault"
  namespace  = var.namespace
  repository = "https://helm.releases.hashicorp.com"
  version    = "0.14.0"
  wait       = true

  values = [
    templatefile("${path.module}/values.tpl", {
      vault_hostname                = var.vault_hostname
      vault_service_account_arn     = var.vault_service_account_arn
      vault_credentials_secret_name = local.vault_secret_name
      vault_config = indent(6, templatefile("${path.module}/vault-config.hcl.tpl", {
        region              = var.region
        dynamodb_table_name = var.vault_dynamodb_table_name
        kms_key_id          = var.vault_kms_key_id
      }))

      kms_key_id = var.vault_kms_key_id
      kms_region = "us-east-1"
    })
  ]
}

resource "time_sleep" "wait_for_vault_credentials" {
  create_duration = "10s"

  depends_on = [
    helm_release.vault
  ]
}

data "kubernetes_secret" "vault_credentials" {
  metadata {
    name      = local.vault_secret_name
    namespace = var.namespace
  }

  // secret was created outisde of terraform, so this is needed to prevent the automatic base64 decode that happens with the regular `data` attribute
  // https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/secret#binary_data
  binary_data = {
    "root-token.enc" = ""
  }

  depends_on = [
    time_sleep.wait_for_vault_credentials
  ]
}

data "aws_kms_secrets" "vault_credentials" {
  secret {
    name    = "root-token"
    payload = data.kubernetes_secret.vault_credentials.binary_data["root-token.enc"]
  }

  depends_on = [
    data.kubernetes_secret.vault_credentials,
    time_sleep.wait_for_vault_credentials,
  ]
}

resource "kubernetes_secret" "vault_root_token" {
  metadata {
    name      = "vault-root-token"
    namespace = var.namespace
  }

  data = {
    token = data.aws_kms_secrets.vault_credentials.plaintext["root-token"]
  }
}
