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
prometheusOperator:
  resources:
    limits:
      cpu: 200m
      memory: 200Mi
    requests:
      cpu: 100m
      memory: 100Mi
  configReloaderCpu: 100m
  configReloaderMemory: 25Mi
prometheus:
  prometheusSpec:
    resources:
      limits:
        cpu: 500m
        memory: 2Gi
      requests:
        cpu: 1
        memory: 4Gi
