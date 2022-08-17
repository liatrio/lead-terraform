output "enable_alertmanager" {
  value = local.enable_alertmanager
}

output "helm_release_name" {
  value = helm_release.kube_prometheus_stack.name
}