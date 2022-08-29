variable "namespace" {}
variable "root_zone_name" {}
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
