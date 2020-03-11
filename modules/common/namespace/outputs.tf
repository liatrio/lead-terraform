output "name" {
  value = (var.enabled && length(kubernetes_namespace.ns) > 0) ? kubernetes_namespace.ns[0].metadata[0].name : ""
}