variable "namespace" {
  type = string
}

variable "kubeconfig_path" {
  type = string
}

variable "admin_password" {
  type = string
}

variable "harbor_hostname" {
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
  namespace                    = var.namespace
  admin_password               = var.admin_password
  k8s_storage_class            = "gp2"
  harbor_registry_disk_size    = "5Gi"
  harbor_chartmuseum_disk_size = "5Gi"
  metrics_enabled              = false
}

output "harbor_hostname" {
  value = module.harbor.hostname
}
