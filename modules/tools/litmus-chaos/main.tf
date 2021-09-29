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
}

resource "helm_release" "litmus_kubernetes_chaos_experiments" {
  repository = "https://litmuschaos.github.io/litmus-helm/"
  name       = "litmus-kubernetes-chaos-experimentes"
  chart      = "kubernetes-chaos"
  version    = "2.1.0"
  namespace  = var.litmus_namespace
  timeout    = 600
  wait       = true
}

resource "kubernetes_service_account" "litmus_service_account" {
  metadata {
    name = "chaos-sa"
    namespace = "litmus"
    labels = {
       name = "chaos-sa"
    }
  }
}

# apiVersion: v1
# kind: ServiceAccount
# metadata:
#   name: chaos-sa
#   namespace: litmus
#   labels:
#     name: pod-delete-sa

# resource "kubernetes_manifest" "litmus_service_account" {
#   manifest = {
#     kind       = "PrometheusRule"
#     apiVersion = "monitoring.coreos.com/v1"
#     metadata = {
#       annotations = {
#         "meta.helm.sh/release-name"      = "kube-prometheus-stack"
#         "meta.helm.sh/release-namespace" = "monitoring"
#         "prometheus-operator-validated"  = "true"
#       }
#       labels = {
#         app                            = "kube-prometheus-stack"
#         "app.kubernetes.io/instance"   = "kube-prometheus-stack"
#         "app.kubernetes.io/managed-by" = "Helm"
#         "app.kubernetes.io/part-of"    = "kube-prometheus-stack"
#         "app.kubernetes.io/version"    = "18.0.3"
#         chart                          = "kube-prometheus-stack-18.0.3"
#         heritage                       = "Helm"
#         release                        = "kube-prometheus-stack"
#       }
#       name      = "kube-prometheus-stack-kubernetes-cluster-at-max-nodes"
#       namespace = "monitoring"
#     }
#     spec = {
#       groups = [
#         {
#           name = "kubernetes-resources"
#           rules = [
#             {
#               alert = "KubeClusterAtMaxNodes"
#               annotations = {
#                 description = "Cluster has scaled to its maximum node capacity and cannot tolerate node failure."
#                 summary     = "Cluster has reached its node limit."
#               }
#               expr = "count(kube_node_status_condition{condition=\"Ready\", status=\"true\"}) == 35"
#               for  = "5m"
#               labels = {
#                 severity = "critical"
#               }
#             }
#           ]
#         }
#       ]
#     }
#   }
# }
