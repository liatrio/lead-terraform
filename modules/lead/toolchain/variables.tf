variable "artifactory_license" {
}

variable "root_zone_name" {
}

variable "cluster" {
}

variable "namespace" {
}

variable "image_whitelist" {
}

variable "issuer_type" {
  default = "selfSigned"
}

variable "elb_security_group_id" {
  default = ""
}

variable "ingress_controller_type" {
  default = "LoadBalancer"
}

variable "enable_xray" {
  default = "true"
}

variable "crd_waiter" {
}

