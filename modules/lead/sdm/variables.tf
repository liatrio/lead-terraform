variable "root_zone_name" {}
variable "cluster" {}
variable "namespace" {}
variable "system_namespace" {}
variable "sdm_version" {}
variable "slack_bot_token" {}
variable "slack_client_signing_secret" {}
variable "workspace_role_name" {}
variable "region" {
  default = "us-east-1"
}