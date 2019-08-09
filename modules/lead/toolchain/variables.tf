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

variable "issuer_server" {
  default = "https://acme-v02.api.letsencrypt.org/directory"
}

variable "elb_security_group_id" {
  default = ""
}

variable "ingress_controller_type" {
  default = "LoadBalancer"
}

variable "ingress_external_traffic_policy" {
  default = ""
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

variable "enable_mailhog" {
  default = true
}

variable "enable_sonarqube" {
  default = true
}

variable "enable_xray" {
  default = true
}

variable "crd_waiter" {
}

variable "keycloak_admin_password" {
}

variable "smtp_json" {
  type    = map
  default = {}
}
