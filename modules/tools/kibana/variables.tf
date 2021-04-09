variable "namespace" {}
variable "elasticsearch_credentials_secret_name" {}
variable "elasticsearch_certificates_secret_name" {}

variable "enable_ingress" {}
variable "kibana_hostname" {
  default = ""
}
