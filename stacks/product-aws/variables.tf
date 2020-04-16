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

variable "load_config_file" {
  default = false
}

variable "pipelines" {
  type = map(object({
    type = string
    repo = string
    org = string
  }))
}

variable "source_type" {
  default = "CODEPIPELINE"
}

variable "codebuild_role" {}
variable "codepipeline_role" {}
variable "s3_bucket" {}
variable "codebuild_user" {}
variable "builder_images_version" {}
variable "product_image_repo" {}
variable "toolchain_image_repo" {}
variable "cluster" {}
