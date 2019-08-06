postgresql:
  resources:
    requests:
      cpu: 20m
      memory: 100Mi
    limits:
      cpu: 100m
      memory: 125Mi
analysis:
  resources:
    requests:
      cpu: 5m
      memory: 150Mi
    limits:
      cpu: 20m
      memory: 200Mi
indexer:
  resources:
    requests:
      cpu: 5m
      memory: 150Mi
    limits:
      cpu: 20m
      memory: 200Mi
persist:
  resources:
    requests:
      cpu: 5m
      memory: 150Mi
    limits:
      cpu: 20m
      memory: 200Mi
server:
  resources:
    requests:
      cpu: 5m
      memory: 150Mi
    limits:
      cpu: 20m
      memory: 200Mi
rabbitmq-ha:
  resources:
    requests:
      cpu: 70m
      memory: 200Mi
    limits:
      cpu: 200m
      memory: 250Mi
mongodb:
  resources:
    requests:
      cpu: 20m
      memory: 250Mi
    limits:
      cpu: 200m
      memory: 300Mi
