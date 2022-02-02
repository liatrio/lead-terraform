resource "helm_release" "sparky" {
  name       = "sparky"
  chart      = "sparky"
  namespace  = var.namespace
  repository = "https://charts.services.liatr.io"
  version    = trimprefix(var.sparky_version, "v")

  values = [
    templatefile("${path.module}/sparky-values.yaml.tpl", {
      image_pull_secret_name = var.image_pull_secret_name
    })
  ]

  set_sensitive {
    name  = "secrets.appToken"
    value = var.slack_app_token
  }

  set_sensitive {
    name  = "secrets.oauthAccessToken"
    value = var.slack_oauth_access_token
  }
}
