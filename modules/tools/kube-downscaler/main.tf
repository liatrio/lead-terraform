resource "helm_release" "kube_downscaler" {
  count      = var.enabled ? 1 : 0
  repository = "https://liatrio-helm.s3.us-east-1.amazonaws.com/charts"
  name       = "kube-downscaler"
  namespace  = var.namespace
  chart      = "kube-downscaler"
  version    = "0.1.0"
  timeout    = 900
  values = [
    templatefile("${path.module}/values.tpl", {
      excluded_namespaces = length(var.excluded_namespaces) > 0 ? join(",", var.excluded_namespaces) : ""
      uptime              = var.uptime
    })
  ]
}
