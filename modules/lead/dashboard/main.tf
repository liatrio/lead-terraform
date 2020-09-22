resource "helm_release" "lead-dashboard" {
  count      = var.enabled ? 1 : 0
  repository = "https://liatrio-helm.s3.us-east-1.amazonaws.com/charts"
  name       = "lead-dashboard"
  namespace  = var.namespace
  chart      = "lead-dashboard"
  version    = var.dashboard_version
  timeout    = 300
}
