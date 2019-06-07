variable "root_zone_name" {} 
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
variable "asg_desired_capacity" {
    default = "3"
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
    default = "0.2.9"
}
variable "dashboard_version" {
  default = "0.2.0-eb0f89d7cf8"
}
variable "artifactory_license" {}
variable "bitbucket_token" {}
variable "jira_token" {}
variable "slack_bot_token" {}
variable "slack_client_signing_secret" {}

locals {
  tags = {
    "Cluster"  = "${var.cluster}"
  }
}
