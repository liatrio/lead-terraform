module "velero_namespace" {
  source = "../../common/namespace"

  resource_limit_cpu    = "100m"
  resource_limit_memory = "256Mi"

  namespace = var.namespace
}

resource "helm_release" "velero" {
  repository = "https://vmware-tanzu.github.io/helm-charts"
  name       = "velero"
  chart      = "velero"
  namespace  = module.velero_namespace.name
  version    = "2.30.1"

  values = [
    templatefile("${path.module}/velero-values.tpl", {
      bucket_name                = var.bucket_name
      region                     = var.region
      cluster_name               = var.cluster_name
      velero_service_account_arn = var.velero_service_account_arn
    })
  ]
}

resource "helm_release" "velero_schedule_toolchain" {
  count     = contains(var.velero_enabled_namespaces, "toolchain") ? 1 : 0
  name      = "velero-schedule-toolchain"
  chart     = "${path.module}/charts/velero-schedule-toolchain"
  namespace = module.velero_namespace.name
  version   = "0.1.0"

  depends_on = [
    helm_release.velero,
  ]
}

resource "helm_release" "velero_schedule_flywheel_production" {
  count     = contains(var.velero_enabled_namespaces, "flywheel-production") ? 1 : 0
  name      = "velero-schedule-flywheel-production"
  chart     = "${path.module}/charts/velero-schedule-flywheel-production"
  namespace = module.velero_namespace.name
  version   = "0.1.0"

  depends_on = [
    helm_release.velero,
  ]
}