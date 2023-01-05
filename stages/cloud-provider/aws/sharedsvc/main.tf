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

data "aws_vpc" "shared_service_vpc" {
  tags = {
    Name = "shared-service-cluster-vpc"
  }
}

data "aws_vpc" "internal_vpn_vpc" {
  tags = {
    Name = "internal-vpn-vpc"
  }
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

data "aws_vpc" "shared_svc" {
  default = false
  tags    = { "Name" = "shared-service-cluster-vpc" }
}

resource "aws_route53_zone" "private_internal_services_liatr_io" {
  name         = "${var.internal_cluster_domain}."

  vpc {
    vpc_id = data.aws_vpc.shared_service_vpc.id
  }

  tags = {
    Environment = "sharedsvc"
    Client      = "liatrio"
    Project     = "Network Infrastructure"
    Owner       = "parker"
    Provisioner = "terraform:liatrio/aws-terraform"
    Private     = "true"
  }
}

resource "aws_route53_zone" "public_internal_services_liatr_io" {
  name = "${var.internal_cluster_domain}."

  tags = {
    Environment = "sharedsvc"
    Client      = "liatrio"
    Project     = "Network Infrastructure"
    Owner       = "parker"
    Provisioner = "terraform:liatrio/aws-terraform"
    Public      = "true"
  }
}

resource "aws_route53_zone" "services_liatr_io" {
  name = "${var.cluster_domain}."
}

resource "aws_route53_record" "services_liatr_io_ns" {
  zone_id = aws_route53_zone.services_liatr_io.zone_id
  name    = "${var.internal_cluster_domain}."
  type    = "NS"
  ttl     = "300"
  records = aws_route53_zone.public_internal_services_liatr_io.name_servers
}

resource "aws_route53_zone_association" "internal_vpn" {
  zone_id = aws_route53_zone.private_internal_services_liatr_io.zone_id
  vpc_id  = data.aws_vpc.internal_vpn_vpc.id
}
