terraform {
  backend "s3" {
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Org       = "liatrio"
      Team      = "flywheel"
      Repo      = "github.com/liatrio/lead-terraform"
      ManagedBy = "terraform"
    }
  }

}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
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

data "aws_route53_zone" "private_internal_services_liatr_io" {
  name         = "${var.internal_cluster_domain}."
  private_zone = true
}

data "aws_route53_zone" "public_internal_services_liatr_io" {
  name = "${var.internal_cluster_domain}."
}

data "aws_route53_zone" "services_liatr_io" {
  name = "${var.cluster_domain}."
}
