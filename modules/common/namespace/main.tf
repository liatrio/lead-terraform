resource "kubernetes_namespace" "ns" {
  count = var.enabled ? 1 : 0
  metadata {
    name        = var.namespace
    annotations = var.annotations
    labels      = var.labels
  }
}

resource "kubernetes_limit_range" "resource-limits" {
  count = var.enabled ? 1 : 0
  metadata {
    name      = "namespace-resource-limits"
    namespace = kubernetes_namespace.ns[0].metadata[0].name
  }
  spec {
    limit {
      type = "Container"
      default_request = {
        cpu    = var.resource_request_cpu
        memory = var.resource_request_memory
      }
      default = {
        cpu    = var.resource_limit_cpu
        memory = var.resource_limit_memory
      }
      max = {
        cpu    = var.resource_max_cpu
        memory = var.resource_max_memory
      }
    }
  }
}

