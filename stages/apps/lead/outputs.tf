output "toolchain_namespace" {
  value = var.toolchain_namespace
  description = "LEAD Toolchain namespace where applications are installed"
}

output "keycloak_hostname" {
  value = module.keycloak.keycloak_hostname
  description = "Keycloak instance url to be used by configuration provider"
}

output "harbor_hostname" {
  value = module.harbor.hostname
}

output "kibana_hostname" {
  value = "kibana.${var.toolchain_namespace}.${var.cluster_name}.${var.root_zone_name}"
}

output "region" {
  value = var.region
}
