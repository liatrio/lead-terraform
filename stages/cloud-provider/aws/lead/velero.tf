module "velero" {
  count = var.enable_velero ? 1 : 0
  source = "../../../../modules/environment/aws/velero"

  cluster_name  = var.cluster_name
  account_id    = data.aws_caller_identity.current.account_id
}