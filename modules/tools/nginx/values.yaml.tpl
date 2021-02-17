controller:
  kind: Deployment
  service:
    enabled: true
    %{ if internal == true }
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-internal: "true"
    %{ endif }
  %{ if default_certificate != "" }
  extraArgs:
    default-ssl-certificate: ${default_certificate}
  %{ endif }
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
