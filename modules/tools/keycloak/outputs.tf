output "keycloak_hostname" {
  depends_on  = [helm_release.keycloak]
  value       = "keycloak.${var.namespace}.${var.cluster}.${var.root_zone_name}"
}

output "keycloak_admin_password" {
  sensitive = true
  value = var.keycloak_admin_password
}

