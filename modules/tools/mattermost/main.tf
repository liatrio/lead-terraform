resource "random_password" "mysql_password" {
  length = 16
}

resource "helm_release" "mattermost" {
  name = "mattermost"

  # the chart is locally vendored until these two PRs are merged:
  # - https://github.com/mattermost/mattermost-helm/pull/208
  # - https://github.com/mattermost/mattermost-helm/pull/209
  chart      = "${path.module}/charts/mattermost-team-edition"
  repository = "https://helm.mattermost.com"
  namespace  = var.namespace
  version    = "3.22.0"
  timeout    = 300

  dependency_update = true # remove this when using remote chart

  values = [
    templatefile("${path.module}/values.yaml.tpl", {
      mattermost_hostname = var.mattermost_hostname
    })
  ]

  set_sensitive {
    name  = "mysql.mysqlPassword"
    value = random_password.mysql_password.result
  }
}
