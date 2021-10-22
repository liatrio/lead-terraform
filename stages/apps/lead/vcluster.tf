module "vcluster" {
  count  = var.enable_vcluster ? 1 : 0
  source = "../../../modules/tools/vcluster"

  vcluster_hostname            = "vcluster.${local.internal_ingress_hostname}"
  host_cluster_service_ip_cidr = var.k8s_service_ip_cidr
}
