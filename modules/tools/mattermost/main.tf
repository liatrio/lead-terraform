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

data "vault_generic_secret" "mattermost" {
  path = var.mattermost_vault_path
}

resource "kubernetes_service_account" "sparky" {
  metadata {
    name      = "sparky-mattermost"
    namespace = var.namespace
  }
}

resource "kubernetes_role" "sparky_mattermost" {
  metadata {
    name      = "sparky-mattermost"
    namespace = var.namespace
  }
  rule {
    api_groups = [
      "sdm.liatr.io"
    ]
    resources  = [
      "products",
      "producttypes"
    ]
    verbs      = [
      "*"
    ]
  }
}

resource "kubernetes_role_binding" "sparky_mattermost" {
  metadata {
    name      = "sparky-mattermost"
    namespace = var.namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.sparky_mattermost.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.sparky.metadata[0].name
    namespace = var.namespace
  }
}

resource "kubernetes_cluster_role" "sparky_mattermost" {
  metadata {
    name = "sparky-mattermost"
  }
  rule {
    api_groups = [
      "sdm.liatr.io"
    ]
    resources  = [
      "builds"
    ]
    verbs      = [
      "*"
    ]
  }
}

resource "kubernetes_cluster_role_binding" "sparky_mattermost" {
  metadata {
    name = "sparky-mattermost"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.sparky_mattermost.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.sparky.metadata[0].name
    namespace = var.namespace
  }
}

resource "helm_release" "sparky_mattermost" {
  name       = "sparky"
  repository = "https://liatrio-helm.s3.us-east-1.amazonaws.com/charts"
  chart      = "sparky-mattermost"

  namespace = var.namespace
  version   = var.sparky_version

  values = [
    templatefile("${path.module}/sparky-values.yaml.tpl", {
      namespace            = var.namespace
      toolchain_image_repo = var.toolchain_image_repo
      sparky_version       = var.sparky_version
      service_account      = kubernetes_service_account.sparky.metadata[0].name
    })
  ]

  set_sensitive {
    name  = "bot.password"
    value = data.vault_generic_secret.mattermost.data["bot-password"]
  }
}
