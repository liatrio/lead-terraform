output "toolchain_namespace" {
  value       = var.toolchain_namespace
  description = "LEAD Toolchain namespace where applications are installed"
}

output "keycloak_hostname" {
  value       = module.keycloak[0].keycloak_hostname
  description = "Keycloak instance url to be used by configuration provider"
}

output "harbor_hostname" {
  value = module.harbor.hostname
}

output "artifactory_jcr_hostname" {
  value = "artifactory-jcr.${var.toolchain_namespace}.${var.cluster_name}.${var.root_zone_name}"
}

output "kibana_hostname" {
  value = module.kibana.hostname
}

output "lead_vault_hostname" {
  value = local.lead_vault_hostname
}

output "lead_vault_token_reviewer_kubernetes_secret_name" {
  value       = kubernetes_service_account.vault_token_reviewer.default_secret_name
  description = "The name of the Kubernetes Secret that contains the service account token Vault will use to verify other Kubernetes service account tokens"
}

output "lead_vault_root_token_kubernetes_secret_name" {
  value       = module.vault.vault_root_token_secret
  description = "The name of the Kubernetes Secret that contains the root token for Vault"
}

output "region" {
  value = var.region
}
