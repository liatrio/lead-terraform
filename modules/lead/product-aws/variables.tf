variable "cluster_domain" {}
variable "cluster" {}
variable "region" {}
variable "product_name" {}
variable "image_whitelist" {
  default = ".*"
}

variable "pipelines" {
  type = map(object({
    type = string
    repo = string
    org  = string
  }))
}

variable "source_type" {}
variable "codebuild_role" {
  default = ""
}
variable "codepipeline_role" {
  default = ""
}
variable "s3_bucket" {}
variable "codebuild_user" {}
variable "builder_images_version" {}
variable "product_image_repo" {}
variable "toolchain_image_repo" {}
variable "codebuild_security_group_id" {}
variable "aws_environment" {}
