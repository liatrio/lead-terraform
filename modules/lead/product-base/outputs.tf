output "staging_namespace" {
  value = module.staging_namespace.name
}

output "production_namespace" {
  value = module.production_namespace.name
}

output "ci_staging_role_name" {
  value = kubernetes_role.ci_staging_role.metadata[0].name
}

output "ci_production_role_name" {
  value = kubernetes_role.ci_production_role.metadata[0].name
}
