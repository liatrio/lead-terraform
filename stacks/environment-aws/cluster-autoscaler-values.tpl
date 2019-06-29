rbac:
  create: true

sslCertPath: /etc/ssl/certs/ca-bundle.crt

cloudProvider: aws
awsRegion: ${region}

autoDiscovery:
  clusterName: ${cluster}
  enabled: true

extraArgs:
  balance-similar-node-groups: true