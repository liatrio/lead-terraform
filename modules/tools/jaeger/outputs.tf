output "jaeger_collector_internal_hostname" {
  value = "jaeger-collector.${var.namespace}.svc.cluster.local"

  depends_on = [
    helm_release.jeager
  ]
}

output "jaeger_collector_zipkin_port" {
  value = local.jaeger_zipkin_port

  depends_on = [
    helm_release.jeager
  ]
}

output "jaeger_query_internal_hostname" {
  value = "jaeger-query.${var.namespace}.svc.cluster.local"

  depends_on = [
    helm_release.jeager
  ]
}

output "jaeger_query_external_hostname" {
  value = local.jaeger_query_external_hostname

  depends_on = [
    helm_release.jeager,
    kubernetes_ingress.jaeger
  ]
}

output "jaeger_query_port" {
  value = local.jaeger_query_port

  depends_on = [
    helm_release.jeager
  ]
}
