provider "kubernetes" {
  alias = "staging"
}

provider "helm" {
  alias = "staging"
}

provider "kubernetes" {
  alias = "production"
}

provider "helm" {
  alias = "production"
}

provider "kubernetes" {
  alias = "system"
}

provider "helm" {
  alias = "system"
}

data "kubernetes_secret" "vault_root_token" {
  provider = kubernetes.system

  metadata {
    namespace = var.vault_namespace
    name      = var.vault_root_token_secret
  }
}

provider "vault" {
  address         = var.vault_address != "" ? var.vault_address : "http://vault.${var.vault_namespace}.svc.cluster.local"
  skip_tls_verify = true
  token           = data.kubernetes_secret.vault_root_token.data["token"]
}
