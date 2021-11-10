controller:
  replicaCount: ${min_replicas}
  kind: Deployment
  service:
    type: ${service_type}
    externalTrafficPolicy: ${ingress_external_traffic_policy}
    enabled: true
    %{ if internal == true }
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-internal: "true"
    %{ endif }
  %{ if length(extra_args) > 0 }
  extraArgs:
    ${indent(4, yamlencode(extra_args))}
  %{~ endif ~}
  autoscaling:
    enabled: true
    targetCPUUtilizationPercentage: 70
    targetMemoryUtilizationPercentage: 85
    minReplicas: ${min_replicas}
  livenessProbe:
    timeoutSeconds: 10
  readinessProbe:
    timeoutSeconds: 10
  publishService:
    enabled: true
  ingressClass: ${ingress_class}
  scope:
    enabled: ${!cluster_wide}
  resources:
    requests:
      cpu: 300m
      memory: 256Mi
    limits:
      cpu: 750m
      memory: 512Mi
defaultBackend:
  resources:
    requests:
      cpu: 1m
      memory: 4Mi
    limits:
      cpu: 1m
      memory: 16Mi
