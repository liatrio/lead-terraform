resources:
  requests:
    cpu: 50m
    memory: 1.5Gi
  limits:
    cpu: 600m
    memory: 2.5Gi
postgresql:
  resources:
    requests:
      cpu: 50m
      memory: 32Mi
    limits:
      cpu: 150m
      memory: 64Mi
