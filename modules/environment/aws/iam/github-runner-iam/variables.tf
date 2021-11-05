variable "name" {
  type = string
}

variable "service_account_name" {
  type = string
}

variable "namespace" {
  type = string
}

variable "roles" {
  type = list(string)
}

variable "aws_iam_openid_connect_provider_arn" {
  type = string
}

variable "aws_iam_openid_connect_provider_url" {
  type = string
}

