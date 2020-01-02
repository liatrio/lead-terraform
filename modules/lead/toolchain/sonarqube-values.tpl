resources:
  requests:
    cpu: 10m
    memory: 1.5Gi
  limits:
    cpu: 300m
    memory: 2.5Gi
postgresql:
  resources:
    requests:
      cpu: 50m
      memory: 64Mi
    limits:
      cpu: 150m
      memory: 256Mi
