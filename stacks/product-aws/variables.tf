variable "product_name" {
}

variable "cluster_domain" {
}

variable "image_whitelist" {
  default = ".*"
}

variable "region" {
  default = "us-east-1"
}

variable "config_context" {
  default = ""
}

variable "pipelines" {
  type = map(object({
    type = string
    repo = string
    org  = string
  }))
}

variable "source_type" {
  default = "CODEPIPELINE"
}

variable "builder_images_version" {}
variable "product_image_repo" {}
variable "toolchain_image_repo" {}
variable "cluster" {}
variable "aws_environment" {}
variable "vault_namespace" {}
variable "vault_root_token_secret" {}

variable "codebuild_role" {
  default = ""
}
variable "codebuild_user" {
  default = ""
}
variable "codebuild_security_group_id" {
  default = ""
}
variable "codepipeline_role" {
  default = ""
}
variable "s3_bucket" {
  default = ""
}
