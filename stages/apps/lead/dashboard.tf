module "dashboard" {
  source                           = "../../modules/lead/dashboard"
  enabled                          = var.enable_dashboard
  namespace                        = module.toolchain.namespace
  dashboard_version                = var.dashboard_version
}
