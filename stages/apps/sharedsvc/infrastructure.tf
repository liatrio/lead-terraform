module "system_namespace" {
  source      = "../../../modules/common/namespace"
  namespace   = var.system_namespace
  annotations = {
    name    = var.system_namespace
    cluster = var.eks_cluster_id
  }
}

module "essential_node_toleration_values" {
  source = "../../../modules/affinity/essential-toleration-values"

  essential_taint_key = var.essential_taint_key
}

module "cluster_autoscaler" {
  source = "../../../modules/tools/cluster-autoscaler"

  cluster                                = var.eks_cluster_id
  region                                 = var.region
  cluster_autoscaler_service_account_arn = var.cluster_autoscaler_service_account_arn
  enable_autoscaler_scale_down           = var.enable_autoscaler_scale_down
  namespace                              = module.system_namespace.name
  extra_values                           = module.essential_node_toleration_values.values
}

module "external_dns" {
  source = "../../../modules/tools/external-dns"

  enabled                     = true
  istio_enabled               = false
  dns_provider                = "aws"
  service_account_annotations = {
    "eks.amazonaws.com/role-arn" = var.external_dns_service_account_arn
  }
  domain_filters              = [
    var.cluster_domain,
    var.internal_cluster_domain
  ]
  namespace                   = module.system_namespace.name
  aws_zone_type               = "private"
  watch_services              = true
}

module "cert_manager" {
  source                                = "../../../modules/tools/cert-manager"
  namespace                             = module.system_namespace.name
  cert_manager_service_account_role_arn = var.cert_manager_service_account_arn
}

module "kube_downscaler" {
  source = "../../../modules/tools/kube-downscaler"

  namespace           = module.system_namespace.name
  uptime              = var.uptime
  excluded_namespaces = [
    "kube-system",
    module.vault_namespace.name
  ]
}

module "aws_node_termination_handler" {
  source = "../../../modules/tools/aws-node-termination-handler"
}

module "kube_janitor" {
  source = "../../../modules/tools/kube-janitor"

  namespace    = module.system_namespace.name
}
