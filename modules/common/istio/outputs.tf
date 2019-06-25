output "namespace" {
  value = "${module.istio_namespace.name}"
}

output "tiller_service_account" {
    value = "${module.istio_namespace.tiller_service_account}"
}