rbac:
  create: false
serviceAccount:
  create: false
  name: ${service_account}
controller:
  publishService:
    enabled: true
  scope: 
    enabled: true
  service:
    type: ${ingress_controller_type}
    externalTrafficPolicy: ${ingress_external_traffic_policy}
  resources:
    requests:
      cpu: 5m
      memory: 128Mi
    limits:
      cpu: 50m
      memory: 256Mi
defaultBackend:
  resources:
    requests:
      cpu: 5m
      memory: 64Mi
    limits:
      cpu: 50m
      memory: 128Mi
