resource "helm_release" "kube-janitor" {
  name       = "kube-janitor"
  namespace  = var.namespace
  repository = "https://themagicalkarp.github.io/charts"
  chart      = "kube-janitor"
  version    = "0.1.0"
  timeout    = 600
  wait       = true

  values     = var.extra_values != "" ? [var.extra_values] : null

  set {
    name  = "image.tag"
    value = "v0.2.1"
  }

  set {
    name  = "kubejanitor.expiration"
    value = 15
  }
}
