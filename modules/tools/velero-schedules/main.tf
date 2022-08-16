resource "kubernetes_manifest" "schedule_velero_backup" {
  for_each = {for schedule in var.schedules:  schedule.name => schedule}
  manifest = {
    "apiVersion" = "velero.io/v1"
    "kind"       = "Schedule"
    "metadata" = {
      "name"      = each.value.name
      "namespace" = "velero"
    }
    "spec" = {
      "schedule" = each.value.interval
      "template" = {
        "includedNamespaces" = each.value.namespaces
        "includedResources" = [
          "*",
        ]
        "labelSelector" = {
          "matchLabels" = each.value.matchLabels
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
    var.velero_status
  ]
}