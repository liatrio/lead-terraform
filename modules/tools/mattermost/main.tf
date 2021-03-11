locals {
  postgres_username = "mattermost"
  postgres_database = "mattermost"
  psotgres_name     = "mattermost-postgresql"
}

resource "random_password" "postgres_password" {
  length  = 16
  special = false
}

resource "helm_release" "postgresql" {
  name       = local.psotgres_name
  namespace  = var.namespace
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  version    = "10.3.11"
  timeout    = 600
  wait       = true

  values = [
    templatefile("${path.module}/postgresql-values.yaml.tpl", {
      postgres_username = local.postgres_username
      postgres_database = local.postgres_database
    })
  ]

  set_sensitive {
    name  = "postgresqlPassword"
    value = random_password.postgres_password.result
  }
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

  dependency_update = true
  # remove this when using remote chart

  values = [
    templatefile("${path.module}/mattermost-values.yaml.tpl", {
      mattermost_hostname = var.mattermost_hostname
      ingress_class       = var.ingress_class
    })
  ]

  set_sensitive {
    name  = "externalDB.externalConnectionString"
    value = format("postgres://%s:%s@%s:5432/%s?sslmode=disable&connect_timeout=10", local.postgres_username, random_password.postgres_password.result, local.psotgres_name, local.postgres_database)
  }

  depends_on = [
    helm_release.postgresql,
  ]
}
