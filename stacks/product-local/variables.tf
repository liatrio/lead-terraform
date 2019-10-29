variable "product_name" {
}

variable "toolchain_namespace" {
  default = "toolchain"
}

variable "cluster_domain" {
}

variable "image_whitelist" {
  default = ".*"
}

variable "issuer_type" {
  default = "acme"
}

variable "issuer_server" {
  default = "https://acme-v02.api.letsencrypt.org/directory"
}

variable "ingress_controller_type" {
  default = "LoadBalancer"
}

variable "config_context" {
  default = ""
}

variable "load_config_file" {
  default = false
}

variable "enable_istio" {
  default = true
}

variable "keycloak_enabled" {
  default = false
}
variable "builder_images_version" {
}
variable "jenkins_image_version" {
}
variable "image_repo" {
}

