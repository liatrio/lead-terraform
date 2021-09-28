resource "helm_release" "litmus_chaos" {
  repository = "https://litmuschaos.github.io/litmus-helm/"
  name       = "litmus"
  chart      = "litmus"
  version    = "2.1.1"
  timeout    = 600
  wait       = true

  values = [
    templatefile("${path.module}/values.tpl", {
      litmus_hostname            = var.litmus_hostname
      litmus_ingress_annotations = var.litmus_ingress_annotations
    })
  ]
}

