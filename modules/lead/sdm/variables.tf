variable "root_zone_name" {
}

variable "cluster" {
}

variable "namespace" {
}

variable "system_namespace" {
}

variable "sdm_version" {
}

variable "product_version" {
}

variable "slack_bot_token" {
}

variable "slack_client_signing_secret" {
}

variable "workspace_role_name" {
  default = "default"
}

variable "enable_operators" {
  default = true
}

variable "region" {
  default = "us-east-1"
}

variable "cert_issuer_type" {
  default = "acme"
}

variable "cert_issuer_server" {
  default = "https://acme-v02.api.letsencrypt.org/directory"
}
