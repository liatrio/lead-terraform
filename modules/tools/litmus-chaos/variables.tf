variable "litmus_hostname" {}

variable "litmus_ingress_annotations" {
  type = map(string)
}

variable "litmus_namespace" {
  default = "litmus"
}
