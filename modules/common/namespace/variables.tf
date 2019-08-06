variable "namespace" {
}

variable "annotations" {
  type    = map(string)
  default = {}
}

variable "labels" {
  type    = map(string)
  default = {}
}

variable "enabled" {
  default = true
}

variable "resource_request_cpu" {
  type = "string"
  default = "10m"
}

variable "resource_request_memory" {
  type = "string"
  default = "64Mi"
}

variable "resource_limit_cpu" {
  type = "string"
  default = "100m"
}

variable "resource_limit_memory" {
  type = "string"
  default = "512Mi"
}
