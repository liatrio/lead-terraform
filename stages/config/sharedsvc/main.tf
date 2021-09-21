terraform {
  backend "s3" {
  }
}

provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "cluster" {
  name = var.eks_cluster_id
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

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", var.eks_cluster_id]
    command     = "aws"
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

provider "keycloak" {
  client_id      = "admin-cli"
  username       = "keycloak"
  password       = data.vault_generic_secret.keycloak.data["admin-password"]
  url            = "https://${var.keycloak_hostname}"
  client_timeout = 15
}

provider "sonarqube" {
  host              = "https://${var.sonarqube_hostname}"
  user              = "admin"
  pass              = data.vault_generic_secret.sonarqube.data["admin"]
  installed_version = "8.5"
}

provider "harbor" {
  url      = "https://${var.harbor_hostname}"
  username = "admin"
  password = data.vault_generic_secret.harbor.data["admin-password"]
}
