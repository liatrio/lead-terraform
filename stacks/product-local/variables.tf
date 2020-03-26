variable "product_name" {
}

variable "toolchain_namespace" {
  default = "toolchain"
}

variable "cluster_domain" {
  default = "localhost"
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

variable "enable_istio" {
  default = true
}

variable "enable_keycloak" {
  default = false
}
variable "builder_images_version" {
  default = "v2.0.0"
}
variable "jenkins_image_version" {
  default = "v2.0.0"
}
variable "toolchain_image_repo" {
  default = "artifactory.toolchain.lead.prod.liatr.io/docker-registry/flywheel"
}

variable "enable_artifactory" {
  default = true
}

variable "product_image_repo" {
  default = "artifactory.toolchain.lead.prod.liatr.io/docker-registry/flywheel"
}

variable "pipelines" {
  type = map(object({
    type = string
    repo = string
    org  = string
  }))
}
