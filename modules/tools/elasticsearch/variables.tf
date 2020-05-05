variable "namespace" {}
variable "root_zone_name" {}
variable "cert_manager_crd_waiter" {}
variable "k8s_storage_class" {
  default = ""
}
variable "local" {
  default = false
}
variable "replicas" {
  default = 3
}
variable "disk_size" {
  default = "15Gi"
}
