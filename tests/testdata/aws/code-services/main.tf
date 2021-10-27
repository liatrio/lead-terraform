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
  name = var.cluster
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

data "aws_caller_identity" "current" {
}

module "code_services" {
  source                      = "../../../../modules/environment/aws/code-services"
  enable_aws_code_services    = true
  account_id                  = data.aws_caller_identity.current.account_id
  cluster                     = var.cluster
  openid_connect_provider_arn = var.openid_connect_provider_arn
  openid_connect_provider_url = var.openid_connect_provider_url
  region                      = var.region
  toolchain_namespace         = var.toolchain_namespace
  vpc_name                    = var.vpc_name
}
