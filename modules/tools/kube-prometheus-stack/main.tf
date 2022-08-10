locals {
  enable_alertmanager = var.prometheus_slack_channel != "" && var.prometheus_slack_webhook_url != ""
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "helm_release" "kube_prometheus_stack" {
  repository = "https://prometheus-community.github.io/helm-charts"
  name       = "kube-prometheus-stack"
  namespace  = var.namespace
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
      enable_alertmanager              = local.enable_alertmanager
      prometheus_slack_webhook_url     = var.prometheus_slack_webhook_url
      prometheus_slack_channel         = var.prometheus_slack_channel
      grafana_hostname                 = var.grafana_hostname
      alertmanager_hostname            = var.alertmanager_hostname
      grafana_ingress_annotations      = var.grafana_ingress_annotations
      alertmanager_ingress_annotations = var.alertmanager_ingress_annotations
    })
  ]
}

resource "helm_release" "prometheus_resources" {
  chart     = "${path.module}/chart"
  name      = "lead-prometheus-resources"
  namespace = var.namespace
  depends_on = [
    helm_release.kube_prometheus_stack,
  ]
}

resource "kubernetes_manifest" "schedule_velero_prometheus_daily_backup" {
  count = var.enable_velero ? 1 : 0
  manifest = {
    "apiVersion" = "velero.io/v1"
    "kind"       = "Schedule"
    "metadata" = {
      "name"      = "prometheus-daily-backup"
      "namespace" = "velero"
    }
    "spec" = {
      "schedule" = "0 1 * * *"
      "template" = {
        "includedNamespaces" = [
          "monitoring",
        ]
        "includedResources" = [
          "*",
        ]
        "labelSelector" = {
          "matchLabels" = {
            "app" = "prometheus"
          }
        }
        "snapshotVolumes" = true
        "storageLocation" = "default"
        "ttl"             = "72h0m0s"
        "volumeSnapshotLocations" = [
          "aws-s3",
        ]
      }
    }
  }
  depends_on = [
    helm_release.kube_prometheus_stack
  ]
}

resource "kubernetes_manifest" "schedule_velero_alertmanager_daily_backup" {
  count = var.enable_velero && local.enable_alertmanager ? 1 : 0
  manifest = {
    "apiVersion" = "velero.io/v1"
    "kind"       = "Schedule"
    "metadata" = {
      "name"      = "alertmanager-daily-backup"
      "namespace" = "velero"
    }
    "spec" = {
      "schedule" = "0 1 * * *"
      "template" = {
        "includedNamespaces" = [
          "monitoring",
        ]
        "includedResources" = [
          "*",
        ]
        "labelSelector" = {
          "matchLabels" = {
            "app" = "alertmanager"
          }
        }
        "snapshotVolumes" = true
        "storageLocation" = "default"
        "ttl"             = "72h0m0s"
        "volumeSnapshotLocations" = [
          "aws-s3",
        ]
      }
    }
  }
  depends_on = [
    helm_release.kube_prometheus_stack,
    var.velero_status
  ]
}
