terraform {
  backend "s3" {
  }
}

provider "aws" {
  region  = var.region
}

data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

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
  alias   = "main"
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

provider "keycloak" {
  client_id      = "admin-cli"
  username       = "keycloak"
  password       = data.vault_generic_secret.keycloak.data["admin-password"]
  url            = "https://${var.keycloak_hostname}"
  initial_login  = false
  client_timeout = 15
}

provider "harbor" {
  url      = "https://${var.harbor_hostname}"
  username = "admin"
  password = data.vault_generic_secret.harbor.data["admin-password"]
}