output "name" {
  value = (var.enabled && length(kubernetes_namespace.ns) > 0) ? kubernetes_namespace.ns[0].metadata[0].name : ""
}

output "tiller_service_account" {
  value = (var.enabled && length(kubernetes_service_account.tiller_service_account) > 0) ? kubernetes_service_account.tiller_service_account[0].metadata[0].name : ""

  depends_on = [kubernetes_role_binding.tiller_role_binding]
}