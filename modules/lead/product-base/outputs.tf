output "staging_namespace" {
  value = module.staging_namespace.name
}

output "staging_service_account" {
  value = module.staging_namespace.tiller_service_account
}

output "production_namespace" {
  value = module.production_namespace.name
}

output "production_service_account" {
  value = module.production_namespace.tiller_service_account
}

output "ci_staging_role_name" {
  value = kubernetes_role.ci_staging_role.name
}

output "ci_production_role_name" {
  value = kubernetes.ci_production_role.name
}
