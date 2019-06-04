
output "namespace" {
  value = "${module.system_namespace.name}"
}
output "tiller_service_account" {
    value = "${module.system_namespace.tiller_service_account}"
}