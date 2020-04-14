provider "aws" {
  version = ">= 2.29.0"
  region  = var.region

  assume_role {
    role_arn = var.aws_assume_role_arn
  }
}

data "aws_availability_zones" "available" {
  filter {
    name  = "region-name"
    values = [var.region]
  }
}

module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  version            = "~> v2.0"
  name               = "${var.cluster}-lead-vpc"
  cidr               = "10.3.0.0/16"
  azs                = [
    data.aws_availability_zones.available.names[0],
    data.aws_availability_zones.available.names[1],
    data.aws_availability_zones.available.names[2],
    data.aws_availability_zones.available.names[0],
    data.aws_availability_zones.available.names[1],
    data.aws_availability_zones.available.names[2]
  ]
  // First 3 subnets are for EKS control plane, second 3 subnets are for nodes
  private_subnets    = [
    "10.3.1.0/24",
    "10.3.2.0/24",
    "10.3.3.0/24",
    "10.3.64.0/18",
    "10.3.128.0/18",
    "10.3.192.0/18"
  ]
  public_subnets     = [
    "10.3.4.0/24",
    "10.3.5.0/24",
    "10.3.6.0/24"
  ]
  enable_nat_gateway = true
  single_nat_gateway = true
  tags               = {
    "kubernetes.io/cluster/${var.cluster}" = "shared",
    "terratest"                            = "terratest"
  }

  private_subnet_tags = {
    "subnet-kind" = "private"
  }

  public_subnet_tags = {
    "subnet-kind" = "public"
  }
}
