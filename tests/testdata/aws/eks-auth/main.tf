provider "aws" {
  version = ">= 2.29.0"
  region  = var.region

  assume_role {
    role_arn = var.aws_assume_role_arn
  }
}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

resource "local_file" "kubeconfig" {
  content = templatefile(
    "${path.module}/kubeconfig.tpl", 
    {
      cluster_name = var.cluster_name,
      certificate-authority-data = data.aws_eks_cluster.cluster.certificate_authority.0.data,
      server = data.aws_eks_cluster.cluster.endpoint,
      token = data.aws_eks_cluster_auth.cluster.token,
    }
  )
  filename = "${var.kubeconfig_path}/kubeconfig"
}