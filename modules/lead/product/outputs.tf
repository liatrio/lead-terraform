output "toolchain_namespace" {
  value = "${module.toolchain_namespace.name}"
}
output "toolchain_service_account" {
    value = "${module.toolchain_namespace.tiller_service_account}"
}
output "staging_namespace" {
  value = "${module.staging_namespace.name}"
}
output "staging_service_account" {
    value = "${module.staging_namespace.tiller_service_account}"
}
output "production_namespace" {
  value = "${module.production_namespace.name}"
}
output "production_service_account" {
    value = "${module.production_namespace.tiller_service_account}"
}