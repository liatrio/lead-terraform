module "cert_manager" {
  source                                = "../../tools/cert-manager"
  namespace                             = var.namespace
  cert_manager_service_account_role_arn = var.cert_manager_service_account_role_arn
  tiller_cluster_role_binding           = kubernetes_cluster_role_binding.tiller_cluster_role_binding
}