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
  default     = "Liatrio"
}

variable "cert_validity_period_hours" {
  description = "Max lifetime for the CA certificate to be valid in hours (default ~3 months)"
  default     = 2160
}

variable "cert_early_renewal_hours" {
  description = "Time before expiration to renew certificate in hours (default ~2 months)"
  default     = 1440
}

variable "enabled" {
  default = true
}
