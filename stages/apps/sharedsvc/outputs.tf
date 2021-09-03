output "vault_hostname" {
  value = local.vault_hostname
}

output "keycloak_namespace" {
  value = module.keycloak_namespace.name
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

output "harbor_hostname" {
  value = module.harbor.hostname
}

output "harbor_namespace" {
  value = module.harbor_namespace.name
}

output "sonar_keycloak_client_id" {
  value = local.sonar_keycloak_client_id
}

output "sonarqube_hostname" {
  value = local.sonarqube_hostname
}

output "sonarqube_collector_url" {
  value = "http://rode-collector-sonarqube.${module.rode_namespace.name}.svc.cluster.local/webhook/event"
}

output "harbor_collector_url" {
  value = "http://rode-collector-harbor.${module.rode_namespace.name}.svc.cluster.local/webhook/event"
}

output "rode_oidc_client_id" {
  value = local.rode_oidc_client_id
}

output "rode_hostname" {
  value = local.rode_hostname
}

output "rode_ui_hostname" {
  value = local.ui_hostname
}
