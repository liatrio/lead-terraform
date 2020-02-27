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

