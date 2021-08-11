resource "helm_release" "aws-node-termination-handler" {
  count      = var.enabled ? 1 : 0
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-node-termination-handler"
  version    = "0.13.3"
  namespace  = var.namespace
  name       = "aws-node-termination-handler"
  timeout    = 600

  values = [
    file("${path.module}/values.yaml")
  ]
}
