module "velero" {
  count = var.enable_velero ? 1 : 0

  source                     = "../../../modules/tools/velero"
  cluster_name               = var.cluster_name
  namespace                  = var.velero_namespace
  bucket_name                = var.velero_bucket_name
  region                     = var.region
  velero_service_account_arn = var.velero_service_account_arn
  schedules                  = var.enable_velero_schedules ? {
      alertmanager = {
        disabled = module.kube_prometheus_stack.enable_alertmanager ? false : true
        schedule = "0 1 * * *"
        useOwnerReferencesInBackup = false
        template = {
          ttl = "240h"
          includedNamespaces = ["monitoring"]
          labelSelector = {
            matchLabels = {
              app = "alertmanager"
            }
          }
          snapshotVolumes = true
          storageLocation = "default"
          volumeSnapshotLocations = ["aws-s3"]
        }
      },
      elasticsearch = {
        disabled = module.elasticsearch.helm_release_name != "" ? false : true
        schedule = "0 1 * * *"
        useOwnerReferencesInBackup = false
        template = {
          ttl = "240h"
          includedNamespaces = ["elasticsearch"]
          labelSelector = {
            matchLabels = {
              chart = "elasticsearch"
              release = "elasticsearch"
            }
          }
          snapshotVolumes = true
          storageLocation = "default"
          volumeSnapshotLocations = ["aws-s3"]
        }
      }
      harbor = {
        disabled = var.enable_harbor ? false : true
        schedule = "0 1 * * *"
        useOwnerReferencesInBackup = false
        template = {
          ttl = "240h"
          includedNamespaces = ["toolchain"]
          labelSelector = {
            matchLabels = {
              app = "harbor"
              release = "harbor"
            }
          }
          snapshotVolumes = true
          storageLocation = "default"
          volumeSnapshotLocations = ["aws-s3"]
        }
      },
  } : {}
}
