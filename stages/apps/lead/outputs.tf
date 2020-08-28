output "toolchain_namespace" {
  value = var.toolchain_namespace
}

output "keycloak_hostname" {
  value = module.keycloak.keycloak_hostname
}

output "harbor_hostname" {
  value = "TBD"
}