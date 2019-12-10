alertmanager:
  enabled: false
kubeStateMetrics:
  deploymentAnnotations:
    downscaler/exclude: "true"
server:
  deploymentAnnotations:
    downscaler/exclude: "true"
  resources:
    requests:
      cpu: 200m
      memory: 2Gi
    limits:
      cpu: 500m
      memory: 4Gi
nodeExporter:
  #priorityClassName: system-node-critical
  tolerations:
  - key: EssentialOnly
    operator: "Exists"
