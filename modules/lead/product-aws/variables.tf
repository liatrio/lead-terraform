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
variable "codebuild_role" {}
variable "codepipeline_role" {}
variable "s3_bucket" {}
variable "codebuild_user" {}
variable "builder_images_version" {}
