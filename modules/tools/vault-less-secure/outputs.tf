output "vault_namespace" {
  value = kubernetes_secret.vault_root_token.metadata[0].namespace
}

output "vault_root_token_secret" {
  value = kubernetes_secret.vault_root_token.metadata[0].name
}
