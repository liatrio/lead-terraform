terraform {
  required_version = ">= 0.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "2.53"
    }
  }
}

provider "aws" {
  region = var.region

  assume_role {
    role_arn = var.aws_assume_role_arn
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster]
    command     = "aws"
  }
}

module "eks" {
  source                                       = "../../../../modules/environment/aws/eks"
  region                                       = var.region
  cluster                                      = var.cluster
  cluster_version                              = "1.15"
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
  vpc_name                                     = var.vpc_name
  enable_public_endpoint                       = true
  codebuild_role                               = ""
}
