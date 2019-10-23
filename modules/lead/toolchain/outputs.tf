output "namespace" {
  value = module.toolchain_namespace.name
  depends_on = [kubernetes_cluster_role_binding.tiller_cluster_role_binding]
}

output "tiller_service_account" {
  value = module.toolchain_namespace.tiller_service_account
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

output "nginx_ingress_waiter" {
  value = module.toolchain_ingress.nginx_ingress_waiter
}
