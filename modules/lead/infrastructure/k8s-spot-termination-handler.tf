resource "helm_release" "k8s_spot_termination_handler" {
  repository = data.helm_repository.stable.metadata[0].name
  chart      = "k8s-spot-termination-handler"
  version    = "1.4.3"
  namespace  = module.system_namespace.name
  name       = "k8s-spot-termination-handler"
  timeout    = 600

  values = [var.ondemand_toleration_values]  
}
