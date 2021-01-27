module "system_namespace" {
  source      = "../../../modules/common/namespace"
  namespace   = var.system_namespace
  annotations = {
    name    = var.system_namespace
    cluster = var.cluster_name
  }
  labels      = {
    "openpolicyagent.org/webhook" = "ignore"
  }
}

module "essential_toleration_values" {
  source = "../../../modules/affinity/essential-toleration-values"
}

module "external_dns" {
  source = "../../../modules/tools/external-dns"

  enabled                     = true
  istio_enabled               = true
  dns_provider                = "aws"
  service_account_annotations = {
    "eks.amazonaws.com/role-arn" = var.external_dns_service_account_arn
  }
  domain_filters              = [
    "${var.cluster_name}.${var.root_zone_name}"
  ]
  namespace                   = module.system_namespace.name
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
  excluded_namespaces = var.downscaler_exclude_namespaces
}

module "aws-node-termination-handler" {
  source = "../../../modules/tools/aws-node-termination-handler"
}

module "kube_janitor" {
  source = "../../../modules/tools/kube-janitor"

  namespace    = module.system_namespace.name
}

module "metrics_server" {
  source = "../../../modules/tools/metrics-server"

  namespace    = module.system_namespace.name
  extra_values = module.essential_toleration_values.values
}

module "cluster_autoscaler" {
  source = "../../../modules/tools/cluster-autoscaler"

  cluster                                = var.cluster_name
  region                                 = var.region
  cluster_autoscaler_service_account_arn = var.cluster_autoscaler_service_account_arn
  enable_autoscaler_scale_down           = var.enable_autoscaler_scale_down
  namespace                              = module.system_namespace.name
  extra_values                           = module.essential_toleration_values.values
}

module "opa" {
  enable_opa         = false
  source             = "../../../modules/common/opa"
  namespace          = module.system_namespace.name
  opa_failure_policy = var.opa_failure_policy
  external_values    = module.essential_toleration_values.values
}
