data "vault_generic_secret" "harbor" {
  path = "lead/aws/${data.aws_caller_identity.current.account_id}/harbor"
}

module "harbor_namespace" {
  source    = "../../../modules/common/namespace"
  namespace = "harbor"
}

module "harbor" {
  source = "../../../modules/tools/harbor"

  harbor_ingress_hostname      = "harbor.${var.cluster_domain}"
  notary_ingress_hostname      = "notary.${var.cluster_domain}"
  ingress_annotations          = local.common_ingress_annotations
  namespace                    = module.harbor_namespace.name
  admin_password               = data.vault_generic_secret.harbor.data["admin-password"]
  k8s_storage_class            = var.k8s_storage_class
  harbor_registry_disk_size    = "200Gi"
  harbor_chartmuseum_disk_size = "100Gi"
  issuer_name                  = module.external_services_cluster_issuer.issuer_name
  issuer_kind                  = module.external_services_cluster_issuer.issuer_kind

  depends_on = [
    module.cert_manager
  ]
}
