module "rode" {
  source = "../../../modules/tools/rode"

  enable_rode              = var.enable_rode
  namespace                = var.toolchain_namespace
  rode_service_account_arn = var.rode_service_account_arn
  cluster                  = var.cluster_name
  root_zone_name           = var.root_zone_name
}
