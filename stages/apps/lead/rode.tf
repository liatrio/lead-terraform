module "rode" {
  source = "../../../modules/tools/rode"

  count = var.enable_rode ? 1 : 0

  namespace                = var.toolchain_namespace
  rode_service_account_arn = var.rode_service_account_arn
  ingress_domain           = "${var.cluster_name}.${var.root_zone_name}"

}
