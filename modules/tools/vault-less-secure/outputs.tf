output "vault_namespace" {
  value = helm_release.vault.namespace
}

output "vault_root_token_secret" {
  value = kubernetes_secret.vault_root_token.metadata[0].name
}
