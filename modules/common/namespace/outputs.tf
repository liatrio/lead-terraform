output "name" {
  value = var.enabled ? kubernetes_namespace.ns[0].metadata[0].name : ""
}

output "tiller_service_account" {
  value = var.enabled ? kubernetes_service_account.tiller_service_account[0].metadata[0].name : ""

  depends_on = [kubernetes_role_binding.tiller_role_binding]
}

output "certificate_watcher_service_account" {
  value = var.enabled ? kubernetes_service_account.certificate_watcher_service_account[0].metadata[0].name : ""

  depends_on = [kubernetes_role_binding.certificate_watcher_role_binding]
}
