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
     image: velero/velero-plugin-for-aws:v1.2.0
     imagePullPolicy: IfNotPresent
     volumeMounts:
       - mountPath: /target
         name: plugins

serviceAccount:
  server:
    create: true
    name: velero
    annotations: