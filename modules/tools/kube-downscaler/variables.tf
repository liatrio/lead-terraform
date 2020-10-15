variable "enabled" {
  default = true
}

variable "namespace" {}
variable "uptime" {}
variable "excluded_namespaces" {
  type    = list(string)
  default = []
}
