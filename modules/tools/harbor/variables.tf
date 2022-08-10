variable "harbor_ingress_hostname" {}

variable "namespace" {}

variable "ingress_annotations" {
  type    = map(string)
  default = {}
}

variable "harbor_registry_disk_size" {
  default = "200Gi"
}

variable "harbor_database_disk_size" {
  default = "10Gi"
}

variable "k8s_storage_class" {}

variable "protect_pvc_resources" {
  default = true
}

variable "admin_password" {}

variable "db_password" {}

variable "metrics_enabled" {
  default = false
}

variable "enable_velero" {
  default = false
}

variable "velero_status" {}