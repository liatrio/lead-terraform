module "github-runners-s3" {
  source = "../../../../modules/environment/aws/github-runners-s3"

  cluster = var.cluster_name
}
