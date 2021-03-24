module "velero_namespace" {
  source = "../../common/namespace"

  resource_limit_cpu    = "100m"
  resource_limit_memory = "256Mi"

  namespace = var.namespace
}

resource "helm_release" "velero" {
  repository = "vmware-tanzu"
  name       = "velero"
  chart      = "vmware-tanzu/velero"
  namespace  = module.velero_namespace.name
  version    = "2.15.0"

  values = [
    templatefile("${path.module}/velero-values.tpl", {
      velero_accesskey_id     = var.velero_aws_access_key_id
      velero_accesskey_secret = var.velero_aws_secret_access_key
      bucket_name             = var.bucket_name
      region                  = var.region
      cluster_name            = var.cluster_name
    })
  ]
}

resource "helm_release" "velero_schedule" {
  name      = "velero-schedule"
  chart     = "${path.module}/charts/velero-schedule"
  namespace = module.velero_namespace.name
  version   = "0.1.0"

  depends_on = [
    helm_release.velero,
  ]
}