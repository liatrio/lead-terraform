variable "domain" {}

variable "region" {
  default = "us-east-1"
}

variable "tags" {
  default = {}
}

variable "create_deployer_credentials" {
  default = false
}

variable "route53_zone_id" {}
