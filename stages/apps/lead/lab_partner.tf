module "lab_partner" {
  count = var.enable_lab_partner ? 1 : 0

  source              = "../../../modules/tools/lab-partner"
  root_zone_name      = var.root_zone_name
  cluster             = var.cluster_name
  namespace           = var.toolchain_namespace
  lab_partner_version = var.lab_partner_version
}
