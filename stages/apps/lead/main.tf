terraform {
  backend "s3" {
  }
}

provider "aws" {
  version = "2.53"
  region  = var.region
}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_caller_identity" "current" {}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
      command     = "aws"
    }
  }
}

provider "vault" {
  address = var.vault_address

  auth_login {
    path = "auth/aws/login"

    parameters = {
      role                    = "aws-admin"
      iam_http_request_method = "POST"
      iam_request_url         = base64encode("https://sts.amazonaws.com/")
      iam_request_body        = base64encode("Action=GetCallerIdentity&Version=2011-06-15")
      iam_request_headers     = var.iam_caller_identity_headers
    }
  }
}
