variable "name" {
  description = "Name of runners"
  default     = "lead"
}

variable "iam_role_name" {
  default     = ""
  description = "When set, the new IAM policy for the s3 bucket will be tied to the provided role. When not set, a new role will be created"
}

variable "region" {
  default     = "us-east-1"
  description = "AWS Region to use for resource creation and reference"
}

variable "service_accounts" {
  default     = []
  description = "a list of service accounts to apply IRSA trust policy to. each service account should be in the format `namespace:name`"
}

variable "aws_iam_openid_connect_provider_url" {}
variable "aws_iam_openid_connect_provider_arn" {}
