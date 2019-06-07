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
    default = "0.2.8"
}
variable "dashboard_version" {
  default = "0.2.0-b55d1623b11"
}
variable "artifactory_license" {}
variable "bitbucket_token" {}
variable "jira_token" {}
variable "slack_webhook_url" {}
variable "slack_access_token" {}
variable "slack_clientid" {}
variable "slack_clientsecret" {}
variable "slack_verification_token" {}

locals {
  tags = {
    "Cluster"  = "${var.cluster}"
  }
}
