output "toolchain_namespace" {
  value = module.toolchain_namespace.name
}

output "toolchain_service_account" {
  value = module.toolchain_namespace.tiller_service_account
}
