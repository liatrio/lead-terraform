postgresql:
  resources:
    requests:
      cpu: 100m
      memory: 128Mi
    limits:
      cpu: 200m
      memory: 256Mi
analysis:
  resources:
    requests:
      cpu: 25m
      memory: 256Mi
    limits:
      cpu: 100m
      memory: 512Mi
indexer:
  resources:
    requests:
      cpu: 25m
      memory: 256Mi
    limits:
      cpu: 100m
      memory: 512Mi
persist:
  resources:
    requests:
      cpu: 25m
      memory: 256Mi
    limits:
      cpu: 100m
      memory: 512Mi
server:
  resources:
    requests:
      cpu: 25m
      memory: 128Mi
    limits:
      cpu: 100m
      memory: 256Mi
rabbitmq-ha:
  resources:
    requests:
      cpu: 100m
      memory: 256Mi
    limits:
      cpu: 200m
      memory: 512Mi
