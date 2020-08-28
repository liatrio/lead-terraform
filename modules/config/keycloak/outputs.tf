output "keycloak_realm_id" {
  value = var.enable_keycloak ? keycloak_realm.realm[0].id : ""
}
