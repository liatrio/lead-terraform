resource "helm_release" "litmus_chaos" {
  repository = "https://litmuschaos.github.io/litmus-helm/"
  name       = "litmus"
  chart      = "litmus"
  version    = "2.1.1"
  namespace  = var.litmus_namespace
  timeout    = 600
  wait       = true

  values = [
    templatefile("${path.module}/values.tpl", {
      litmus_hostname            = var.litmus_hostname
      litmus_ingress_annotations = var.litmus_ingress_annotations
    })
  ]
}

resource "helm_release" "litmus_kubernetes_chaos_experiments" {
  repository = "https://litmuschaos.github.io/litmus-helm/"
  name       = "litmus-kubernetes-chaos-experiments"
  chart      = "kubernetes-chaos"
  version    = "2.15.0"
  namespace  = var.litmus_namespace
  timeout    = 600
  wait       = true
}
