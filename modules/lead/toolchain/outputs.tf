
output "namespace" {
  value = "${module.toolchain_namespace.name}"
}
output "tiller_service_account" {
    value = "${module.toolchain_namespace.tiller_service_account}"
}