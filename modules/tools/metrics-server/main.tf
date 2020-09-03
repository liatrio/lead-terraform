data "helm_repository" "bitnami" {
  name = "bitnami"
  url  = "https://charts.bitnami.com/bitnami"
}

resource "helm_release" "metrics" {
  name       = "metrics-server"
  namespace  = var.namespace
  repository = data.helm_repository.bitnami.metadata[0].name
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
