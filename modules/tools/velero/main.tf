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