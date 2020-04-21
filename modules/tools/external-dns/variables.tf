variable "enabled" {
  type    = bool
  default = true
}

variable "dns_provider" {
  type    = string
  default = "aws"
}

variable "domain_filter" {
  type = string
}

variable "service_account_annotations" {
  type    = map(string)
  default = {}
}

variable "namespace" {
  type = string
}
