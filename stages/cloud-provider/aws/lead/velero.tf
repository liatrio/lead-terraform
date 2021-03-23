module "velero" {
  source = "../../../../modules/environment/aws/velero"

  velero_user                                  = var.velero_user
  enable_velero                                = var.enable_velero
  cluster_name                                 = var.cluster_name
  account_id                                   = data.aws_caller_identity.current.account_id
}