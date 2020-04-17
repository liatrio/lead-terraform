data "aws_vpc" "lead_vpc" {
  tags = {
    Name = "${var.aws_environment}-lead-vpc"
  }
}

data "aws_subnet_ids" "eks_workers" {
  vpc_id = data.aws_vpc.lead_vpc.id

  filter {
    name   = "tag:subnet-kind"
    values = [
      "private"
    ]
  }

  filter {
    name   = "cidr-block"
    values = [
      "*/18"
    ]
  }
}

module "codeservices" {
  source                      = "../../modules/environment/aws/code-services"
  enable_aws_code_services    = var.enable_aws_code_services
  cluster                     = var.cluster
  region                      = var.region
  account_id                  = data.aws_caller_identity.current.account_id
  toolchain_namespace         = var.toolchain_namespace
  openid_connect_provider_arn = module.eks.aws_iam_openid_connect_provider.arn
  openid_connect_provider_url = module.eks.aws_iam_openid_connect_provider.url
  aws_environment             = var.aws_environment
  aws_vpc_subnet_arns_json    = jsonencode(formatlist("arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:subnet/%s", data.aws_subnet_ids.eks_workers.ids))
}
