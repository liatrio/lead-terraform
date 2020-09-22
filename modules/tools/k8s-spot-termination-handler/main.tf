resource "helm_release" "k8s_spot_termination_handler" {
  count      = var.enabled ? 1 : 0
  repository = "https://kubernetes-charts.storage.googleapis.com"
  chart      = "k8s-spot-termination-handler"
  version    = "1.4.9"
  namespace  = var.namespace
  name       = "k8s-spot-termination-handler"
  timeout    = 600

  values     = [
    file("${path.module}/values.yaml")
  ]
}
