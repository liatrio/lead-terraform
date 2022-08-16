terraform {
  backend "s3" {
  }
}

provider "aws" {
  region = var.region
}

data "aws_eks_cluster" "cluster" {
  name = var.eks_cluster_id
}

data "aws_caller_identity" "current" {}

locals {
  external_ingress_annotations = {
    "nginx.ingress.kubernetes.io/force-ssl-redirect" : true
    "nginx.ingress.kubernetes.io/proxy-body-size" : "0"
    "kubernetes.io/ingress.class" : module.nginx_external.ingress_class
  }

  internal_ingress_annotations = {
    "nginx.ingress.kubernetes.io/force-ssl-redirect" : true
    "nginx.ingress.kubernetes.io/proxy-body-size" : "0"
    "kubernetes.io/ingress.class" : module.nginx.ingress_class
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", var.eks_cluster_id]
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
      args        = ["eks", "get-token", "--cluster-name", var.eks_cluster_id]
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
