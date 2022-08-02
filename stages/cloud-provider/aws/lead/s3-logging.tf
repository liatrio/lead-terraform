module "s3-logging" {
  source = "../../../../modules/environment/aws/s3-logging"

  cluster_name = var.cluster_name
  account_id   = data.aws_caller_identity.current.account_id
}