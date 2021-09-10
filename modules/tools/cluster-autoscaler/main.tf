resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = var.namespace
  repository = "https://kubernetes.github.io/autoscaler"
  timeout    = 600
  wait       = true
  version    = "9.10.7"

  values = [
    templatefile("${path.module}/cluster-autoscaler-values.tpl", {
      cluster            = var.cluster
      region             = var.region
      scale_down_enabled = var.enable_autoscaler_scale_down
      iam_arn            = var.cluster_autoscaler_service_account_arn
    }),
    var.extra_values != "" ? var.extra_values : null
  ]
}
