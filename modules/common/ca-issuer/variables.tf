variable "name" {
  description = "CA certificate name"
}

variable "namespace" {
  description = "Kubernetes namespace to install CA issuer into"
}

variable "cert-manager-crd" {
  description = "Cert Manager CRD dependency"
}


variable "common_name" {
  description = "Common name of CA certificate"
}

variable "organization_name" {
  description = "Organization name of CA certificate"
  default = "Liatrio"
}