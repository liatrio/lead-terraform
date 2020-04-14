provider "aws" {
  version = ">= 2.29.0"
  region  = var.region

  assume_role {
    role_arn = var.aws_assume_role_arn
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
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
}

module "eks" {
  source                                       = "../../../../modules/environment/aws/eks"
  region                                       = var.region
  cluster                                      = var.cluster
  cluster_version                              = "1.15"
  system_namespace                             = "default"
  toolchain_namespace                          = "default"
  preemptible_instance_types                   = ["m5.large", "c5.large", "m4.large", "c4.large", "t3.large", "r5.large"]
  preemptible_asg_min_size                     = 1
  preemptible_asg_desired_capacity             = 1
  preemptible_asg_max_size                     = 2
  essential_instance_type                      = "t3.large"
  essential_asg_min_size                       = 1
  essential_asg_desired_capacity               = 1
  essential_asg_max_size                       = 2
  essential_taint_key                          = "EssentialOnly"
  on_demand_percentage                         = 0
  protect_from_scale_in                        = false
  write_kubeconfig                             = true
  kubeconfig_aws_authenticator_additional_args = ["-r", var.aws_assume_role_arn]
  enable_aws_code_services                     = false
  aws_environment                              = var.cluster
  vpc_id                                       = module.vpc.vpc_id
  enable_public_endpoint                       = true
}
