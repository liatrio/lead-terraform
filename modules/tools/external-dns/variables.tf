variable "enabled" {
  type    = bool
  default = true
}

variable "istio_enabled" {
  type = bool
}

variable "watch_services" {
  type        = bool
  default     = false
  description = "when true, externaldns will create DNS entries for kubernetes service resources"
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

variable "aws_zone_type" {
  default = "public"
}

variable "release_name" {
  default = "external-dns"
}

variable "exclude_domains" {
  type = list(string)
  default = []
}
