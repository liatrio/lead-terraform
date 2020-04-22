module "system_namespace" {
  source      = "../../modules/common/namespace"
  namespace   = var.system_namespace
  annotations = {
    name    = var.system_namespace
    cluster = module.eks.cluster_id
  }
  labels      = {
    "openpolicyagent.org/webhook" = "ignore"
  }
}

data "template_file" "essential_toleration" {
  template = file("${path.module}/essential-toleration.tpl")
  vars     = {
    essential_taint_key = var.essential_taint_key
  }
}

module "external_dns" {
  source = "../../modules/tools/external-dns"

  enabled                     = true
  dns_provider                = "aws"
  service_account_annotations = {
    "eks.amazonaws.com/role-arn" = module.external_dns_iam.external_dns_service_account_arn
  }
  domain_filter               = "${module.eks.cluster_id}.${var.root_zone_name}"
  namespace                   = module.system_namespace.name
}

module "cert_manager" {
  source                                = "../../modules/tools/cert-manager"
  namespace                             = module.system_namespace.name
  cert_manager_service_account_role_arn = module.cert_manager_iam.cert_manager_service_account_arn
}

module "kube_downscaler" {
  source = "../../modules/tools/kube-downscaler"

  namespace           = module.system_namespace.name
  uptime              = var.uptime
  excluded_namespaces = var.downscaler_exclude_namespaces
  extra_values        = data.template_file.essential_toleration.rendered
}

module "k8s_spot_termination_handler" {
  source = "../../modules/tools/k8s-spot-termination-handler"
}

module "kube_janitor" {
  source = "../../modules/tools/kube-janitor"

  namespace    = module.system_namespace.name
  extra_values = data.template_file.essential_toleration.rendered
}

module "metrics_server" {
  source = "../../modules/tools/metrics-server"

  namespace    = module.system_namespace.name
  extra_values = data.template_file.essential_toleration.rendered
}

module "cluster_autoscaler" {
  source = "../../modules/tools/cluster-autoscaler"

  cluster                                = var.cluster
  region                                 = var.region
  cluster_autoscaler_service_account_arn = module.cluster_autoscaler_iam.cluster_autoscaler_service_account_arn
  enable_autoscaler_scale_down           = var.enable_autoscaler_scale_down
  namespace                              = module.system_namespace.name
  extra_values                           = data.template_file.essential_toleration.rendered
}

module "opa" {
  enable_opa         = false
  source             = "../../modules/common/opa"
  namespace          = module.system_namespace.name
  opa_failure_policy = var.opa_failure_policy
  external_values    = data.template_file.essential_toleration.rendered
}
