variable "kube_config_path" {}

variable "tiller_service_account" {}

variable "namespace" {}

variable "issuer_name" {
  default = "lead-namespace-issuer"
}

variable "issuer_kind" {
  default = "Issuer"
}

variable "issuer_type" {
}

variable "issuer_server" {
  default = "https://acme-staging-v02.api.letsencrypt.org/directory"
}

variable "crd_waiter" {
  default = ""
}