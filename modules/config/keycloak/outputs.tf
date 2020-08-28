output "keycloak_admin_username" {
  value = kubernetes_secret.keycloak_admin.data.username
}

output "keycloak_realm_id" {
  value = var.enable_keycloak ? keycloak_realm.realm[0].id : ""
}

output "keycloak_admin_credential_secret" {
  value = kubernetes_secret.keycloak_admin.metadata[0].name
}
