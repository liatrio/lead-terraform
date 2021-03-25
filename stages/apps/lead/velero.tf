module "velero" {
  count = var.enable_velero ? 1 : 0

  source                       = "../../../modules/tools/velero"
  cluster_name                 = var.cluster_name
  namespace                    = var.velero_namespace
  bucket_name                  = var.velero_bucket_name
  region                       = var.region
  velero_service_account_arn   = var.velero_service_account_arn
  velero_enabled_namespaces    = var.velero_enabled_namespaces
}