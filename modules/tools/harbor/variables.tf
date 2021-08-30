variable "harbor_ingress_hostname" {}

variable "notary_ingress_hostname" {}

variable "namespace" {}

variable "ingress_annotations" {}

variable "harbor_registry_disk_size" {
  default = "200Gi"
}

variable "harbor_chartmuseum_disk_size" {
  default = "100Gi"
}

variable "harbor_database_disk_size" {
  default = "10Gi"
}

variable "k8s_storage_class" {}

variable "issuer_name" {}

variable "issuer_kind" {}

variable "protect_pvc_resources" {
  default = true
}

variable "admin_password" {}
