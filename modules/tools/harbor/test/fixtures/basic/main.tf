variable "namespace" {
  type = string
}

variable "kubeconfig_path" {
  type = string
}

variable "admin_password" {
  type = string
}

variable "db_password" {
  type = string
}

variable "harbor_hostname" {
  type = string
}

variable "enable_velero" {
  type = bool
}

variable "velero_status" {
  type = string
}

module "harbor" {
  source = "../../../"

  harbor_ingress_hostname = var.harbor_hostname
  ingress_annotations = {
    "nginx.ingress.kubernetes.io/force-ssl-redirect" : true
    "nginx.ingress.kubernetes.io/proxy-body-size" : "0"
    "kubernetes.io/ingress.class" : "vcluster"
  }
  namespace                 = var.namespace
  admin_password            = var.admin_password
  db_password               = var.db_password
  k8s_storage_class         = "gp2"
  harbor_registry_disk_size = "5Gi"
  metrics_enabled           = false
  enable_velero             = var.enable_velero
  velero_status             = var.velero_status
}

output "harbor_hostname" {
  value = module.harbor.hostname
}
