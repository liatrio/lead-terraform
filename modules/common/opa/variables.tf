variable "namespace" {}

variable "enable_opa" {
  default = "true"
}

variable "opa_failure_policy" {
  default = "Fail"
}

variable "external_values" {
  default = ""
}
