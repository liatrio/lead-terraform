resource "helm_release" "metrics" {
  name       = "metrics-server"
  namespace  = var.namespace
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "metrics-server"
  version    = "4.2.2"
  timeout    = 600
  wait       = true

  set {
    name  = "args[0]"
    value = "--kubelet-insecure-tls"
  }
  set {
    name  = "args[1]"
    value = "--kubelet-preferred-address-types=InternalIP"
  }

  values = var.extra_values != "" ? [var.extra_values] : null
}
