ingress:
  enabled: true
  hosts:
  - ${ingress_hostname}
  annotations:
    kubernetes.io/ingress.class: "toolchain-nginx"
  tls:
  - hosts:
    - ${ingress_hostname}
postgresql:
  resources:
    requests:
      cpu: 150m
      memory: 75Mi
    limits:
      cpu: 600m
      memory: 125Mi
analysis:
  resources:
    requests:
      cpu: 10m
      memory: 150Mi
    limits:
      cpu: 50m
      memory: 200Mi
indexer:
  resources:
    requests:
      cpu: 10m
      memory: 150Mi
    limits:
      cpu: 50m
      memory: 200Mi
persist:
  resources:
    requests:
      cpu: 10m
      memory: 150Mi
    limits:
      cpu: 50m
      memory: 200Mi
server:
  service:
    type: ClusterIP
  resources:
    requests:
      cpu: 10m
      memory: 150Mi
    limits:
      cpu: 50m
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
