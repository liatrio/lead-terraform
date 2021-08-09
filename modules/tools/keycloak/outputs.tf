output "keycloak_hostname" {
  depends_on  = [helm_release.keycloak]
  value       = "keycloak.${var.cluster_domain}"
}

output "keycloak_admin_credential_secret" {
  value = kubernetes_secret.keycloak_credentials.metadata[0].name
}
