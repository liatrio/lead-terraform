variable "enabled" {
  default = true
}
variable "local" {
  default = false
}

variable "root_zone_name" {
}

variable "cluster" {
}

variable "cluster_domain" {
}

variable "namespace" {
}

variable "dashboard_version" {
}

variable "enable_keycloak" {
  default = false
}

variable "keycloak_realm_id" {
}

variable "crd_waiter" {
}

variable "k8s_storage_class" {}

variable "elasticsearch_replicas" {
  default = 3
}
