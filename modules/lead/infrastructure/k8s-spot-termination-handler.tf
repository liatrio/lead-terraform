resource "helm_release" "k8s_spot_termination_handler" {
  count      = var.enable_spot_instances ? 1 : 0
  repository = data.helm_repository.stable.metadata[0].name
  chart      = "k8s-spot-termination-handler"
  version    = "1.4.3"
  namespace  = module.system_namespace.name
  name       = "k8s-spot-termination-handler"
  timeout    = 600

  set_string {
    name  = "nodeSelector.kubernetes\\.io/lifecycle"
    value = "spot"
  }
}
