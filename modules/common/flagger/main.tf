data "helm_repository" "flagger" {
  count = var.enable ? 1 : 0
  name  = "flagger.app"
  url   = "https://flagger.app"
}

resource "helm_release" "flagger" {
  count      = var.enable ? 1 : 0
  repository = data.helm_repository.flagger[0].metadata[0].name
  chart      = "flagger"
  namespace  = var.namespace
  name       = "flagger"
  timeout    = 600
  wait       = true
  version    = "0.17.0"

  set {
    name  = "meshProvider"
    value = var.provider
  }

  set {
    name  = "metricsServer"
    value = var.metrics_url
  }

  set {
    name  = "slack.user"
    value = var.slack_user
  }

  set {
    name  = "slack.channel"
    value = var.slack_channel
  }

  set {
    name  = "slack.url"
    value = var.slack_url
  }
}

