output "vault_hostname" {
  value = local.vault_hostname
}

output "keycloak_realm" {
  value = local.keycloak_realm
}

output "keycloak_issuer_uri" {
  value = local.keycloak_issuer_uri
}

output "keycloak_hostname" {
  value = module.keycloak.keycloak_hostname
}
