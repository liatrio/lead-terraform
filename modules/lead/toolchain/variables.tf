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

variable "issuer_name" {}

variable "issuer_kind" {}

variable "elb_security_group_id" {
  default = ""
}

variable "enable_istio" {
  default = true
}

variable "enable_artifactory" {
  default = true
}

variable "enable_gitlab" {
  default = true
}

variable "enable_keycloak" {
  default = true
}

variable "keycloak_hostname" {
}

variable "keycloak_realm_id" {
}

variable "enable_sonarqube" {
  default = true
}

variable "enable_harbor" {
  default = true
}

variable "harbor_admin_password" {
}

variable "enable_rode" {
  default = true
}

variable "crd_waiter" {
}

variable "harbor_registry_disk_size" {
  default = "200Gi"
}

variable "harbor_chartmuseum_disk_size" {
  default = "100Gi"
}

variable "k8s_storage_class" {}

variable "rode_service_account_arn" {}
