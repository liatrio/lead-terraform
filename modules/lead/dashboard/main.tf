data "helm_repository" "liatrio" {
  name = "liatrio"
  url  = "https://liatrio-helm.s3.us-east-1.amazonaws.com/charts"
}

resource "helm_release" "lead-dashboard" {
  count      = var.enabled ? 1 : 0
  repository = data.helm_repository.liatrio.metadata[0].name
  name       = "lead-dashboard"
  namespace  = var.namespace
  chart      = "lead-dashboard"
  version    = var.dashboard_version
  timeout    = 300
}
