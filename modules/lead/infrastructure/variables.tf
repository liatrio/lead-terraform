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

variable "issuer_server" {
  default = "https://acme-v02.api.letsencrypt.org/directory"
}

variable "essential_toleration_values" {
  default = ""
}

variable "cert_manager_service_account_role_arn" {
  default = ""
}

variable "uptime" {
}

variable "external_dns_service_account_annotations" {
  type = map
  default = {}
}

variable "downscaler_exclude_namespaces" {
  type = list(string)
  default = ["kube-system"]
}
