locals {
  enable_alertmanager = var.prometheus_slack_channel != "" && var.prometheus_slack_webhook_url != ""
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus-stack"
  namespace  = var.namespace
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "18.0.3"
  timeout    = 600
  wait       = true

  set_sensitive {
    name  = "grafana.adminPassword"
    value = random_password.password.result
  }

  values = [
    templatefile("${path.module}/values.tpl", {
      enable_alertmanager          = local.enable_alertmanager
      prometheus_slack_webhook_url = var.prometheus_slack_webhook_url
      prometheus_slack_channel     = var.prometheus_slack_channel
      grafana_hostname             = var.grafana_hostname
      ingress_annotations          = var.ingress_annotations
    })
  ]
}

resource "kubernetes_manifest" "prometheus_rule_kube_overcommit-max-nodes" {
  manifest = {
    kind       = "PrometheusRule"
    apiVersion = "monitoring.coreos.com/v1"
    metadata = {
      annotations = {
        "meta.helm.sh/release-name"     = "kube-prometheus-stack"
        "meta.helm.sh/release-namespace" = "monitoring"
        "prometheus-operator-validated"    = "true"
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
      name      = "kube-prometheus-stack-kubernetes-overcommit-max-nodes"
      namespace = "monitoring"
    }
    spec = {
      groups = [
        {
          name = "kubernetes-resources"
          rules = [
            {
              alert = "KubeMemoryOvercommitWithMaxNodes"
              annotations = {
                description = "Cluster has overcommitted memory resource requests for Pods and cannot tolerate node failure."
                runbook_url = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubememoryovercommit"
                summary     = "Cluster has overcommitted memory resource requests."
              }
              expr = "sum(namespace_memory:kube_pod_container_resource_requests:sum{})\n  /\nsum(kube_node_status_allocatable{resource=\"memory\"})\n  \u003e\n((count(kube_node_status_allocatable{resource=\"memory\"}) \u003e 1) - 1)\n  /\ncount(kube_node_status_allocatable{resource=\"memory\"})"
              for  = "5m"
              labels = {
                severity = "warning"
              }
            }
          ]
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "kube_prometheus_harbor_monitor" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "kube-prometheus-stack-harbor"
      namespace = var.namespace
      labels = {
        app     = "kube-prometheus-stack-harbor"
        release = "kube-prometheus-stack"
      }
    }
    spec = {
      selector = {
        matchLabels = {
          app     = "harbor"
          release = "harbor"
        }
      }
      endpoints = [{
        port = "metrics"
      }]
      namespaceSelector = {
        any = "false"
        matchNames = [
          "toolchain",
          "harbor"
        ]
      }
    }
  }
}
