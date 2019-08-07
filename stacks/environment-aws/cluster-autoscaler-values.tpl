rbac:
  create: true

sslCertPath: /etc/ssl/certs/ca-bundle.crt

cloudProvider: aws
awsRegion: ${region}

autoDiscovery:
  clusterName: ${cluster}
  enabled: true
  tags:
    - "k8s.io/cluster-autoscaler/enabled"
    - "k8s.io/cluster-autoscaler/${cluster}"
    - "kubernetes.io/cluster/${cluster}"

extraArgs:
  balance-similar-node-groups: true
  scale-down-enabled: ${scale_down_enabled}
