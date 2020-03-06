output "namespace" {
  value = module.system_namespace.name
}

output "tiller_service_account" {
  value      = module.system_namespace.tiller_service_account
  depends_on = [kubernetes_cluster_role_binding.tiller_cluster_role_binding]
}

output "crd_waiter" {
  value = module.cert_manager.crd_waiter
}

