data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

resource "helm_release" "k8s_spot_termination_handler" {
  count      = var.enabled ? 1 : 0
  repository = data.helm_repository.stable.metadata[0].name
  chart      = "k8s-spot-termination-handler"
  version    = "1.4.3"
  namespace  = "kube-system"
  name       = "k8s-spot-termination-handler"
  timeout    = 600

  values     = [
    file("${path.module}/values.yaml")
  ]
}
