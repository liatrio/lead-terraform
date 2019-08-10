variable "cluster" {
}

variable "namespace" {
}

variable "external_dns_chart_values" {
}

variable "enable_opa" {
  default = "true"
}

variable "opa_failure_policy" {
}

variable "acme_dns_providers" {
  type    = list(string)
  default = []
}

variable "issuer_type" {
}

variable "uptime" {
}
