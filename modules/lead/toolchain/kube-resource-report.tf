module "kube_resource_report" {
  source = "../../tools/kube-resource-report"

  cluster        = var.cluster
  namespace      = var.namespace
  root_zone_name = var.root_zone_name
}