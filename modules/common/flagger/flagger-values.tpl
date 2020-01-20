meshProvider: ${mesh_provider}
metricsServer: ${metrics_server}
eventWebhook: ${event_webhook}
crd:
  create: ${crd_create}

resources:
  limits:
    memory: 64Mi
    cpu: 25m
  requests:
    memory: 32Mi
    cpu: 10m
