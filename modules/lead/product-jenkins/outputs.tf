output "toolchain_namespace" {
  value = module.toolchain_namespace.name
}

output "staging_namespace" {
  value = module.product_base.staging_namespace
}

output "production_namespace" {
  value = module.product_base.production_namespace
}
