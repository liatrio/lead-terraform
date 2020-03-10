variable "product_name" {
}

variable "toolchain_namespace" {
  default = "toolchain"
}

variable "cluster_domain" {
  default = "svc.local"
}

variable "image_whitelist" {
  default = ".*"
}

variable "config_context" {
  default = ""
}

variable "load_config_file" {
  default = false
}
