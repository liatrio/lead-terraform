variable "cluster_name" {
  description = "Cluster name"
  default     = "lead"
}

variable "region" {
  default     = "us-east-1"
  description = "AWS Region to use for resource creation and reference"
}

variable "service_accounts" {
  default     = []
  description = "a list of service accounts to apply IRSA trust policy to. each service account should be in the format `namespace:name`"
}
variable "aws_iam_openid_connect_provider" {
}
