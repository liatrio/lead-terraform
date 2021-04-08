module "github-runners-s3" {
  source = "../../../../modules/environment/aws/github-runners-s3"

  cluster_name = var.cluster_name
  aws_iam_openid_connect_provider = module.eks.aws_iam_openid_connect_provider 
}
