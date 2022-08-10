replicaCount: 2

image:
  repository: k8s.gcr.io/autoscaling/cluster-autoscaler
  tag: v1.20.0

rbac:
  create: true
  serviceAccount:
    annotations:
      "eks.amazonaws.com/role-arn": ${iam_arn}

resources:
  requests:
    memory: 100Mi
    cpu: 100m
  limits:
    memory: 600Mi
    cpu: 500m

sslCertPath: /etc/ssl/certs/ca-bundle.crt

cloudProvider: aws
awsRegion: ${region}

autoDiscovery:
  clusterName: ${cluster}
  enabled: true
  tags:
    - "k8s.io/cluster-autoscaler/enabled"
    - "kubernetes.io/cluster/${cluster}"

extraArgs:
  balance-similar-node-groups: true
  skip-nodes-with-local-storage: false
  scale-down-enabled: ${scale_down_enabled}