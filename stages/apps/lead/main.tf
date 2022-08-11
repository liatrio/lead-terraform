terraform {
  backend "s3" {
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Org       = "liatrio",
      Team      = "flywheel",
      Repo      = "github.com/liatrio/lead-terraform",
      ManagedBy = "terraform"
    }
  }

}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_vpc" "vpc" {
  id = data.aws_eks_cluster.cluster.vpc_config[0].vpc_id
}

data "aws_caller_identity" "current" {}

locals {
  external_ingress_annotations = {
    "nginx.ingress.kubernetes.io/force-ssl-redirect" : true
    "nginx.ingress.kubernetes.io/proxy-body-size" : "0"
    "kubernetes.io/ingress.class" : "toolchain-nginx"
  }

  internal_ingress_annotations = {
    "nginx.ingress.kubernetes.io/force-ssl-redirect" : true
    "nginx.ingress.kubernetes.io/proxy-body-size" : "0"
    "kubernetes.io/ingress.class" : "internal-nginx"
  }

  external_ingress_hostname = "toolchain.${var.cluster_name}.${var.root_zone_name}"
  internal_ingress_hostname = "internal.${var.cluster_name}.${var.root_zone_name}"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
  experiments {
    manifest_resource = true
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
    path   = "auth/aws/login"
    method = "aws"

    parameters = {
      role = var.vault_role
    }
  }
}
