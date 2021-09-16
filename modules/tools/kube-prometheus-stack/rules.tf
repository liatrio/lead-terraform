resource "kubernetes_manifest" "prometheus_rule_kube_cluster-at-max-nodes" {
  manifest = {
    kind       = "PrometheusRule"
    apiVersion = "monitoring.coreos.com/v1"
    metadata = {
      annotations = {
        "meta.helm.sh/release-name"      = "kube-prometheus-stack"
        "meta.helm.sh/release-namespace" = "monitoring"
        "prometheus-operator-validated"  = "true"
      }
      labels = {
        app                            = "kube-prometheus-stack"
        "app.kubernetes.io/instance"   = "kube-prometheus-stack"
        "app.kubernetes.io/managed-by" = "Helm"
        "app.kubernetes.io/part-of"    = "kube-prometheus-stack"
        "app.kubernetes.io/version"    = "18.0.3"
        chart                          = "kube-prometheus-stack-18.0.3"
        heritage                       = "Helm"
        release                        = "kube-prometheus-stack"
      }
      name      = "kube-prometheus-stack-kubernetes-cluster-at-max-nodes"
      namespace = "monitoring"
    }
    spec = {
      groups = [
        {
          name = "kubernetes-resources"
          rules = [
            {
              alert = "KubeClusterAtMaxNodes"
              annotations = {
                description = "Cluster has scaled to its maximum node capacity and cannot tolerate node failure."
                summary     = "Cluster has reached its node limit."
              }
              expr = "count(kube_node_status_condition{condition=\"Ready\", status=\"true\"}) == 35"
              for  = "5m"
              labels = {
                severity = "critical"
              }
            }
          ]
        }
      ]
    }
  }
}


# INFO: This resource is commented out as we don't currently want this rule deployed
#
# resource "kubernetes_manifest" "prometheus_rule_kube_overcommit-max-nodes" {
#   manifest = {
#     kind       = "PrometheusRule"
#     apiVersion = "monitoring.coreos.com/v1"
#     metadata = {
#       annotations = {
#         "meta.helm.sh/release-name"     = "kube-prometheus-stack"
#         "meta.helm.sh/release-namespace" = "monitoring"
#         "prometheus-operator-validated"    = "true"
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
#       name      = "kube-prometheus-stack-kubernetes-overcommit-max-nodes"
#       namespace = "monitoring"
#     }
#     spec = {
#       groups = [
#         {
#           name = "kubernetes-resources"
#           rules = [
#             {
#               alert = "KubeMemoryOvercommitWithMaxNodes"
#               annotations = {
#                 description = "Cluster has overcommitted memory resource requests for Pods and cannot tolerate node failure."
#                 runbook_url = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubememoryovercommit"
#                 summary     = "Cluster has overcommitted memory resource requests."
#               }
#               expr = "sum(namespace_memory:kube_pod_container_resource_requests:sum{})\n  /\nsum(kube_node_status_allocatable{resource=\"memory\"})\n  \u003e\n((count(kube_node_status_allocatable{resource=\"memory\"}) \u003e 1) - 1)\n  /\ncount(kube_node_status_allocatable{resource=\"memory\"})"
#               for  = "5m"
#               labels = {
#                 severity = "warning"
#               }
#             }
#           ]
#         }
#       ]
#     }
#   }
# }

