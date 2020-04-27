variable "enabled" {
  type    = bool
  default = true
}

variable "istio_enabled" {
  type    = bool
}

variable "dns_provider" {
  type    = string
  default = "aws"
}

variable "domain_filters" {
  type = list(string)
}

variable "service_account_annotations" {
  type    = map(string)
  default = {}
}

variable "namespace" {
  type = string
}
