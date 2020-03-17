variable "product_name" {
}

variable "cluster_domain" {
}

variable "image_whitelist" {
  default = ".*"
}

variable "region" {
  default = "us-east-1"
}

variable "config_context" {
  default = ""
}

variable "load_config_file" {
  default = false
}
