server:
  resources:
    requests:
      cpu: 200m
      memory: 2Gi
    limits:
      cpu: 500m
      memory: 4Gi
nodeExporter:
  priorityClassName: system-node-critical