variable "cluster" {
}

variable "namespace" {
}

variable "external_dns_chart_values" {
}

variable "enable_opa" {
  default = "true"
}

variable "enable_downscaler" {
  default = "true"
}

variable "enable_k8s_spot_termination_handler" {
  default = "true"
}

variable "opa_failure_policy" {
}

variable "acme_dns_providers" {
  type    = list(string)
  default = []
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
