rbac:
  create: false
serviceAccount:
  create: false
  name: ${service_account}
controller:
  autoscaling:
    enabled: true
    targetCPUUtilizationPercentage: 80
    targetMemoryUtilizationPercentage: 80
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
      memory: 128Mi
    limits:
      cpu: 50m
      memory: 200Mi
defaultBackend:
  resources:
    requests:
      cpu: 5m
      memory: 32Mi
    limits:
      cpu: 10m
      memory: 64Mi
