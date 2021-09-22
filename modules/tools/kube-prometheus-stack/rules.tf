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

resource "kubernetes_manifest" "prometheus_rule_kube_oom-kill" {
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
      name      = "kube-prometheus-stack-kubernetes-oom-kill"
      namespace = "monitoring"
    }
    spec = {
      groups = [
        {
          name = "kubernetes-resources"
          rules = [
            {
              alert = "HostOomKillDetected"
              annotations = {
                description = "Alert for host OOM kill detected."
                summary     = "Host OOM kill detected."
              }
              expr = "increase(node_vmstat_oom_kill[1m]) > 0"
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
