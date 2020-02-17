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
  default = "selfSigned"
}

variable "issuer_server" {
  default = ""
}

variable "ingress_controller_type" {
  default = "NodePort"
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

variable "enable_keycloak" {
  default = false
}
variable "builder_images_version" {
}
variable "jenkins_image_version" {
}
variable "image_repo" {
}

variable "enable_artifactory" {
  default = true
}
