resource "helm_release" "sonarqube" {
  repository = "https://oteemo.github.io/charts"
  name       = "sonarqube"
  namespace  = var.namespace
  chart      = "sonarqube"
  version    = "9.6.3"
  timeout    = 1200
  wait       = true

  set_sensitive {
    name  = "postgresql.postgresPassword"
    value = var.postgres_password
  }

  set_sensitive {
    name  = "account.adminPassword"
    value = var.admin_password
  }

  set_sensitive {
    name  = "sonarProperties.sonar\\.auth\\.oidc\\.clientSecret\\.secured"
    value = var.keycloak_client_secret
  }

  values = [
    templatefile("${path.module}/sonarqube-values.tpl", {
      ingress_enabled      = var.ingress_enabled
      ingress_hostname     = var.ingress_hostname
      ingress_annotations  = var.ingress_annotations
      force_authentication = var.force_authentication
      enable_keycloak      = var.enable_keycloak
      keycloak_issuer_uri  = var.keycloak_issuer_uri
      keycloak_client_id   = var.keycloak_client_id
    })
  ]
}
resource "kubernetes_manifest" "schedule_velero_sonarqube_daily_backup" {
  count = var.enable_velero ? 1 : 0
  manifest = {
    "apiVersion" = "velero.io/v1"
    "kind"       = "Schedule"
    "metadata" = {
      "name"      = "sonarqube-daily-backup"
      "namespace" = "velero"
    }
    "spec" = {
      "schedule" = "0 1 * * *"
      "template" = {
        "includedNamespaces" = [
          "toolchain",
        ]
        "includedResources" = [
          "*",
        ]
        "labelSelector" = {
          "matchLabels" = {
            "release" = "sonarqube"
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
    helm_release.sonarqube,
    var.velero_status
  ]
}