output "ingress_class" {
  value = var.ingress_class

  depends_on = [
    helm_release.nginx_ingress
  ]
}
