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
  
credentials:
  secretContents:
    cloud: |
      [default]
      aws_access_key_id=${velero_accesskey_id}
      aws_secret_access_key=${velero_accesskey_secret}

serviceAccount:
  server:
    create: true
    name: velero
    annotations: