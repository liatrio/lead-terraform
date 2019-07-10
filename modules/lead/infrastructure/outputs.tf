output "namespace" {
  value = module.system_namespace.name
}

output "tiller_service_account" {
  value      = module.system_namespace.tiller_service_account
  depends_on = [kubernetes_cluster_role_binding.tiller_cluster_role_binding]
}

output "crd_waiter" {
  value = null_resource.cert_manager_crd_delay.id
}

