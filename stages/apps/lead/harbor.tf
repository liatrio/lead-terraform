data "vault_generic_secret" "harbor" {
  path = "lead/aws/${data.aws_caller_identity.current.account_id}/harbor"
}

module "harbor" {
  source = "../../../modules/tools/harbor"

  count                        = var.enable_harbor ? 1 : 0
  harbor_ingress_hostname      = "harbor.toolchain.${var.cluster_name}.${var.root_zone_name}"
  notary_ingress_hostname      = "notary.toolchain.${var.cluster_name}.${var.root_zone_name}"
  ingress_annotations          = local.common_ingress_annotations
  namespace                    = var.toolchain_namespace
  admin_password               = data.vault_generic_secret.harbor.data["admin-password"]
  k8s_storage_class            = var.k8s_storage_class
  harbor_registry_disk_size    = "200Gi"
  harbor_chartmuseum_disk_size = "100Gi"
  issuer_name                  = module.cluster_issuer.issuer_name
  issuer_kind                  = module.cluster_issuer.issuer_kind
  metrics_enabled              = true

  depends_on = [
    module.cert_manager
  ]
}
