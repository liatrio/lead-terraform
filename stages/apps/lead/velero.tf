module "velero" {
  count = var.enable_velero ? 1 : 0

  source              = "../../../modules/tools/velero"
  cluster_name        = var.cluster_name
  namespace           = var.velero_namespace
  bucket_name         = var.velero_bucket_name
  region              = var.region
  velero_aws_access_key_id = var.velero_aws_access_key_id
  velero_aws_secret_access_key = var.velero_aws_secret_access_key
}