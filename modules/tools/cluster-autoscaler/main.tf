data "template_file" "cluster_autoscaler" {
  template = file("${path.module}/cluster-autoscaler-values.tpl")

  vars = {
    cluster            = var.cluster
    region             = var.region
    scale_down_enabled = var.enable_autoscaler_scale_down
    iam_arn            = var.cluster_autoscaler_service_account_arn
  }
}

resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  namespace  = var.namespace
  repository = "https://kubernetes-charts.storage.googleapis.com"
  chart      = "cluster-autoscaler"
  timeout    = 600
  wait       = true
  version    = "6.6.1"

  values = [
    data.template_file.cluster_autoscaler.rendered,
    var.extra_values != "" ? var.extra_values : null
  ]
}
