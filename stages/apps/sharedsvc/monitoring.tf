module "monitoring_namespace" {
  source    = "../../../modules/common/namespace"
  namespace = "monitoring"
  annotations = {
    name    = "monitoring"
    cluster = var.eks_cluster_id
  }
}

module "kube_prometheus_stack" {
  source = "../../../modules/tools/kube-prometheus-stack"

  namespace        = module.monitoring_namespace.name
  grafana_hostname = "grafana.${var.internal_cluster_domain}"
}

module "dashboard" {
  source = "../../../modules/lead/dashboard"

  namespace         = module.monitoring_namespace.name
  dashboard_version = var.dashboard_version
}
