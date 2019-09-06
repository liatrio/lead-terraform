rbac:
  create: false
serviceAccount:
  create: false
  name: ${service_account}
controller:
  autoscaling:
    enabled: true
    targetCPUUtilizationPercentage: 80
    targetMemoryUtilizationPercentage: 95
  livenessProbe:
    timeoutSeconds: 10
  readinessProbe:
    timeoutSeconds: 10
  publishService:
    enabled: true
  scope:
    enabled: true
  service:
    type: ${ingress_controller_type}
    externalTrafficPolicy: ${ingress_external_traffic_policy}
  resources:
    requests:
      cpu: 15m
      memory: 140Mi
    limits:
      cpu: 50m
      memory: 160Mi
defaultBackend:
  resources:
    requests:
      cpu: 1m
      memory: 4Mi
    limits:
      cpu: 1m
      memory: 16Mi
