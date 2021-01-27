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
  chart      = "${path.module}/charts"
  timeout    = 600
  wait       = true
  version    = "9.4.0"

  values = [
    data.template_file.cluster_autoscaler.rendered,
    var.extra_values != "" ? var.extra_values : null
  ]
}
