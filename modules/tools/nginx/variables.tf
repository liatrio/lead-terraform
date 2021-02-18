variable "name" {
  default = ""
}

variable "namespace" {
  default = "nginx"
}

variable "service_type" {
  default = "LoadBalancer"
}

variable "internal" {
  default = false
}

variable "default_certificate" {
  default = ""
}

variable "ingress_class" {
  default = "nginx"
}

variable "ingress_external_traffic_policy" {
  default = ""
}

variable "cluster_wide" {
  default = true
}
