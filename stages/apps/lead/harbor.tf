data "vault_generic_secret" "harbor" {
  path = "lead/aws/${data.aws_caller_identity.current.account_id}/harbor"
}

module "harbor" {
  source = "../../../modules/tools/harbor"

  enable                       = var.enable_harbor
  cluster                      = var.cluster_name
  namespace                    = var.toolchain_namespace
  admin_password               = data.vault_generic_secret.harbor.data["admin-password"]
  root_zone_name               = var.root_zone_name
  k8s_storage_class            = var.k8s_storage_class
  harbor_registry_disk_size    = "200Gi"
  harbor_chartmuseum_disk_size = "100Gi"
  issuer_name                  = module.cluster_issuer.issuer_name
  issuer_kind                  = module.cluster_issuer.issuer_kind

  depends_on = [
    module.cert_manager
  ]
}
