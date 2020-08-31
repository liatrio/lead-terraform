module "dashboard" {
  source                           = "../../../modules/lead/dashboard"

  enabled                          = var.enable_dashboard
  namespace                        = var.toolchain_namespace
  dashboard_version                = var.dashboard_version
}
