rbac:
  create: true
  serviceAccount:
    annotations: 
      "eks.amazonaws.com/role-arn": ${iam_arn}

sslCertPath: /etc/ssl/certs/ca-bundle.crt

cloudProvider: aws
awsRegion: ${region}

autoDiscovery:
  clusterName: ${cluster}
  enabled: true
  tags:
    - "kubernetes.io/cluster-autoscaler/enabled"
    - "kubernetes.io/cluster/${cluster}"

extraArgs:
  balance-similar-node-groups: true
  skip-nodes-with-local-storage: false
  scale-down-enabled: ${scale_down_enabled}
