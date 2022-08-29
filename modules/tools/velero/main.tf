locals {
  test_template = yamlencode({
    configuration : {
      provider: "aws"

      backupStorageLocation : {
        name: "default"
        bucket: var.bucket_name
        prefix: var.cluster_name
        config : {
          region: var.region
        }
      }

      volumeSnapshotLocation: {
        name: "aws-s3"
        config: {
          region: var.region
        }
      }
    }

    initContainers: [{
      name: "velero-plugin-for-aws"
      image: "velero/velero-plugin-for-aws:v1.5.0"
      imagePullPolicy: "IfNotPresent"
      volumeMounts: [{
        mountPath: "/target"
        name: "plugins"
      }]}
    ]

    serviceAccount: {
      server : {
        create: true
        name: "velero"
        annotations: {
          "eks.amazonaws.com/role-arn": var.velero_service_account_arn
        }
      }
    }

    securityContext: {
      fsGroup: 65534
    }

    schedules: var.schedules
  })
}

module "velero_namespace" {
  source = "../../common/namespace"

  resource_limit_cpu    = "100m"
  resource_limit_memory = "256Mi"

  namespace = var.namespace
}

resource "helm_release" "velero" {
  repository = "https://vmware-tanzu.github.io/helm-charts"
  name       = "velero"
  chart      = "velero"
  namespace  = module.velero_namespace.name
  version    = "2.30.1"

  values     = [local.test_template]
  # values = [
  #   templatefile("${path.module}/velero-values.tpl", {
  #     bucket_name                = var.bucket_name
  #     region                     = var.region
  #     cluster_name               = var.cluster_name
  #     velero_service_account_arn = var.velero_service_account_arn
  #     schedules                  = var.schedules
  #   })
  # ]
}
