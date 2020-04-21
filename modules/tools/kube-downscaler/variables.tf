variable "enabled" {
  default = true
}

variable "extra_values" {
  default = ""
}

variable "namespace" {}
variable "uptime" {}
variable "excluded_namespaces" {
  type    = list(string)
  default = []
}
