configuration:
  provider: aws

  backupStorageLocation:
    name: default
    bucket: ${bucket_name}
    prefix: ${cluster_name}
    config:
      region: ${region}

  volumeSnapshotLocation:
    name: aws-s3
    config:
      region: ${region}

initContainers:
   - name: velero-plugin-for-aws
     image: velero/velero-plugin-for-aws:v1.5.0
     imagePullPolicy: IfNotPresent
     volumeMounts:
       - mountPath: /target
         name: plugins

serviceAccount:
  server:
    create: true
    name: velero
    annotations:
      eks.amazonaws.com/role-arn: "${velero_service_account_arn}"

securityContext:
  fsGroup: 65534

schedules:
%{ for schedule in schedules ~}
  ${schedule.name}:
    disabled: false
    schedule: ${schedule.interval}
    useOwnerReferencesInBackup: false
    template:
      ttl: "240h"
      includedNamespaces:
      ${chomp(indent(8, yamlencode(schedule.namespaces)))}
      matchLabels:
      ${indent(8, yamlencode(schedule.matchLabels))}
%{ endfor }
