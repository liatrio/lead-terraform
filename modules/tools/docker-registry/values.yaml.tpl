storage: s3
secrets:
  s3:
    accessKey: ${aws_access_key_id}
s3:
  bucket: ${s3_bucket_name}
  region: ${region}
  secure: true
ingress:
  enabled: true
  hosts:
    - ${hostname}
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/proxy-body-size: "0"
  tls:
    - hosts:
       - ${hostname}
configData:
  version: 0.1
  log:
    level: debug
    fields:
      service: registry
  storage:
    cache:
      blobdescriptor: inmemory
  http:
    addr: :5000
    headers:
      X-Content-Type-Options: [nosniff]
  health:
    storagedriver:
      enabled: true
      interval: 10s
      threshold: 3
  proxy:
    remoteurl: https://registry-1.docker.io
