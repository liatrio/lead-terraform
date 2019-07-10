output "name" {
  value = kubernetes_namespace.ns.metadata[0].name
}

output "tiller_service_account" {
  value = kubernetes_service_account.tiller_service_account.metadata[0].name

  depends_on = [kubernetes_role_binding.tiller_role_binding]
}

