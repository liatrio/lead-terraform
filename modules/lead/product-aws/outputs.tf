output "staging_namespace" {
  value = module.product_base.staging_namespace
}

output "staging_service_account" {
  value = module.product_base.staging_service_account
}

output "production_namespace" {
  value = module.product_base.production_namespace
}

output "production_service_account" {
  value = module.product_base.production_service_account
}

output "ci_staging_role_name" {
  value = module.product_base.ci_staging_role_name
}

output "ci_production_role_name" {
  value = module.product_base.ci_production_role_name
}
