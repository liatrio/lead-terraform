output "nginx_ingress_waiter" {
  value = var.enabled ? helm_release.nginx_ingress[0].metadata.0.revision : ""
}
