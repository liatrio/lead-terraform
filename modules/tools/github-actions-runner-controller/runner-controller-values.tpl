replicaCount: ${controller_replica_count}

syncPeriod: 1m

authSecret:
  create: false
  name: ${secret_name}

scope:
  singleNamespace: true
  watchNamespace: ""

githubWebhookServer:
  enabled: true
  syncPeriod: 1m
  ingress:
    enabled: true
    hostName: ${ingress_hostname}
    annotations:
      ${indent( 4, yamlencode( github_webhook_annotations ) ) }
    hosts:
    - host: ${ingress_hostname}
      paths:
        - path: /
          pathType: ImplementationSpecific
    tls:
    - hosts:
      - ${ingress_hostname}
