output "keycloak_hostname" {
  depends_on  = [helm_release.keycloak]
  value       = "keycloak.${var.namespace}.${var.cluster}.${var.root_zone_name}"
}
