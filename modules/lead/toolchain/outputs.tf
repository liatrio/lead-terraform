output "namespace" {
  value = module.toolchain_namespace.name
  depends_on = [kubernetes_cluster_role_binding.tiller_cluster_role_binding]
}

output "keycloak_domain" {
  depends_on  = [helm_release.keycloak]
  value       = "keycloak.${module.toolchain_namespace.name}.${var.cluster}.${var.root_zone_name}"
}

output "keycloak_admin_username" {
  value = kubernetes_secret.keycloak_admin.data.username
}

output "keycloak_admin_password" {
  sensitive = true
  value = var.keycloak_admin_password
}

output "keycloak_realm_id" {
  value = var.enable_keycloak ? keycloak_realm.realm[0].id : ""
}

output "keycloak_admin_credential_secret" {
  value = kubernetes_secret.keycloak_admin.metadata[0].name
}

output "keycloak_hostname" {
  value = local.keycloak_hostname
}
