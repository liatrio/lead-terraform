resource "helm_release" "litmus_chaos" {
  repository = "https://litmuschaos.github.io/litmus-helm/"
  name       = "litmus"
  chart      = "litmus"
  version    = "2.1.1"
  namespace  = var.litmus_namespace
  timeout    = 600
  wait       = true

  values = [
    templatefile("${path.module}/values.tpl", {
      litmus_hostname            = var.litmus_hostname
      litmus_ingress_annotations = var.litmus_ingress_annotations
    })
  ]
  set {
    name  = "env"
    value = {"INGRESS" = "true"} 
  }
}

resource "helm_release" "litmus_kubernetes_chaos_experiments" {
  repository = "https://litmuschaos.github.io/litmus-helm/"
  name       = "litmus-kubernetes-chaos-experiments"
  chart      = "kubernetes-chaos"
  version    = "2.15.0"
  namespace  = var.litmus_namespace
  timeout    = 600
  wait       = true
}

# resource "kubernetes_service_account" "litmus_service_account" {
#   metadata {
#     name = "chaos-sa"
#     namespace = var.litmus_namespace
#     labels = {
#        name = "chaos-sa-label"
#     }
#   }
# }

# resource "kubernetes_role" "litmus_role" {
#   metadata {
#     name = "chaos-sa"
#     namespace = var.litmus_namespace
#     labels = {
#        name = "chaos-sa"
#     }
#   }
#   rule {
#     api_groups     = ["","litmuschaos.io","batch","apps"]
#     resources      = ["pods","deployments","pods/log","events","jobs","chaosengines","chaosexperiments","chaosresults"]
#     verbs          = ["create","list","get","patch","update","delete","deletecollection"]
#   }
# }

# resource "kubernetes_role_binding" "litmus_role_binding" {
#   metadata {
#     name = "chaos-sa"
#     namespace = var.litmus_namespace
#     labels = {
#        name = "chaos-sa-label"
#     }
#   }
#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "Role"
#     name      = "chaos-sa"
#   }
#   subject {
#     kind      = "ServiceAccount"
#     name      = "chaos-sa"
#     namespace = var.litmus_namespace
#   }
# }
