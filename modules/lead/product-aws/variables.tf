variable "cluster_domain" {}
variable "product_name" {}
variable "image_whitelist" {}

variable "pipelines" {
  type = map(object({
    sourcelocation = string
    sourcerepo = string
    sourcebranch = string
  }))
}

variable "source_type" {
  default = "CODECOMMIT"
}

variable "codebuild_role" {}
variable "codepipeline_role" {}
variable "s3_bucket" {}
