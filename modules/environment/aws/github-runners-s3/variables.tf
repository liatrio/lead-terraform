variable "cluster_name" {
  description = "Cluster name"
  default = "lead"
}

variable "region" {
  default = "us-east-1"
  description = "AWS Region to use for resource creation and reference"
}

variable "service_account" {
  default = "github-runners-liatrio:actions-runner"
  description = "Serivce account for IAM role"
}
variable "aws_iam_openid_connect_provider" {
}
