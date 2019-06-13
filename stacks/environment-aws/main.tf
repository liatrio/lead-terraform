terraform {
  backend "s3" {}
}

provider "aws" {
  version = ">= 1.47.0"
  region  = "${var.region}"
}

data "aws_eks_cluster" "cluster" {
  name = "${module.eks.cluster_id}"
}

data "aws_eks_cluster_auth" "cluster" {
  name = "${data.aws_eks_cluster.cluster.name}"
}

provider "kubernetes" {
  host = "${data.aws_eks_cluster.cluster.endpoint}"
  cluster_ca_certificate = "${base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)}"
  token                  = "${data.aws_eks_cluster_auth.cluster.token}"
  load_config_file       = false
}

provider "helm" {
  alias = "system"
  namespace = "${module.infrastructure.namespace}"
  tiller_image = "gcr.io/kubernetes-helm/tiller:v2.14.1"
  service_account = "${module.infrastructure.tiller_service_account}"

  kubernetes {
    host                   = "${data.aws_eks_cluster.cluster.endpoint}"
    cluster_ca_certificate = "${base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)}"
    token                  = "${data.aws_eks_cluster_auth.cluster.token}"
    load_config_file       = false
  }
}

provider "helm" {
  alias = "toolchain"
  namespace = "${module.toolchain.namespace}"
  tiller_image = "gcr.io/kubernetes-helm/tiller:v2.14.1"
  service_account = "${module.toolchain.tiller_service_account}"

  kubernetes {
    host                   = "${data.aws_eks_cluster.cluster.endpoint}"
    cluster_ca_certificate = "${base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)}"
    token                  = "${data.aws_eks_cluster_auth.cluster.token}"
    load_config_file       = false
  }
}