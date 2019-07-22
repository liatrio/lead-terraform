variable "root_zone_name" {
}

variable "cluster" {
  default = "lead"
}

variable "system_namespace" {
  default = "lead-system"
}

variable "toolchain_namespace" {
  default = "toolchain"
}

variable "region" {
  default = "us-east-1"
}

variable "key_name" {
  default = ""
}

variable "instance_type" {
  default = "m5.large"
}

variable "asg_min_size" {
  default = "1"
}

variable "asg_desired_capacity" {
  default = "1"
}

variable "asg_max_size" {
  default = "5"
}

variable "worker_ami_name_filter" {
  default = "v20190329"
}

variable "image_whitelist" {
  default = ".*"
}

variable "opa_failure_policy" {
  default = "Fail"
}

variable "sdm_version" {
  default = "0.4.0-24-gd13bfe5"
}

variable "product_version" {
  default = "master"
}

variable "dashboard_version" {
  default = "0.2.0-4346ee7d548"
}

variable "artifactory_license" {
}

variable "slack_bot_token" {
}

variable "slack_client_signing_secret" {
}

locals {
  tags = {
    "Cluster" = var.cluster
  }
}

