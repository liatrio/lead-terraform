rbac:
  create: false
serviceAccount:
  create: false
  name: ${service_account}
controller:
  autoscaling:
    enabled: true
    targetCPUUtilizationPercentage: 70
    targetMemoryUtilizationPercentage: 85
  livenessProbe:
    timeoutSeconds: 10
  readinessProbe:
    timeoutSeconds: 10
  publishService:
    enabled: true
  ingressClass: ${ingress_class}
  %{ if default_certificate != "" }
  extraArgs:
    default-ssl-certificate: ${default_certificate}
  %{ endif }
  scope:
    enabled: ${!cluster_wide}
  service:
    type: ${ingress_controller_type}
    externalTrafficPolicy: ${ingress_external_traffic_policy}
    %{ if length(service_annotations) != 0 }
    annotations:
      ${indent(6, yamlencode(service_annotations))}
    %{ endif }
    %{ if length(service_load_balancer_source_ranges) != 0 }
    loadBalancerSourceRanges:
      ${indent(6, yamlencode(service_load_balancer_source_ranges))}
    %{ endif }
  resources:
    requests:
      cpu: 300m
      memory: 256Mi
    limits:
      cpu: 750m
      memory: 512Mi
  %{ if length(deployment_annotations) != 0 }
  deploymentAnnotations:
    ${indent(4, yamlencode(deployment_annotations))}
  %{ endif }
defaultBackend:
  resources:
    requests:
      cpu: 10m
      memory: 4Mi
    limits:
      cpu: 100m
      memory: 16Mi
