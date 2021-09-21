# INFO: Service Monitor for harbor will work in k8s 1.18.8
#
# resource "kubernetes_manifest" "kube_prometheus_harbor_monitor" {
#   manifest = {
#     apiVersion = "monitoring.coreos.com/v1"
#     kind       = "ServiceMonitor"
#     metadata = {
#       name      = "kube-prometheus-stack-harbor"
#       namespace = var.namespace
#       labels = {
#         app     = "kube-prometheus-stack-harbor"
#         release = "kube-prometheus-stack"
#       }
#     }
#     spec = {
#       selector = {
#         matchLabels = {
#           app     = "harbor"
#           release = "harbor"
#         }
#       }
#       endpoints = [{
#         port = "metrics"
#       }]
#       namespaceSelector = {
#         any = "false"
#         matchNames = [
#           "toolchain",
#           "harbor"
#         ]
#       }
#     }
#   }
# }
