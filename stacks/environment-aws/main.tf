terraform {
  backend "s3" {
  }
}

provider "aws" {
  version = "2.53"
  region  = var.region
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_caller_identity" "current" {}

data "aws_eks_cluster_auth" "cluster" {
  name = data.aws_eks_cluster.cluster.name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

provider "helm" {
  version = "1.1.1"

  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
    load_config_file       = false
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

provider "keycloak" {
  client_id      = "admin-cli"
  username       = "keycloak"
  password       = data.vault_generic_secret.keycloak.data["admin-password"]
  url            = var.root_zone_name == "localhost" ? "http://${var.cluster}.${var.root_zone_name}" : "https://${var.cluster}.${var.root_zone_name}"
  initial_login  = false
  client_timeout = 15
}

provider "harbor" {
  url      = "https://harbor.${var.toolchain_namespace}.${var.cluster}.${var.root_zone_name}"
  username = "admin"
  password = data.vault_generic_secret.harbor.data["admin-password"]
}

