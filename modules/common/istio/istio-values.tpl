gateways:
  istio-egressgateway:
    enabled: false
  istio-ingressgateway:
    autoscaleMax: 10
    cpu:
      targetAverageUtilization: 70
    sds:
      enabled: true
      resources:
        requests:
          cpu: 10m
          memory: 128Mi
        limits:
          cpu: 100m
          memory: 256Mi
    resources:
      requests:
        cpu: 200m
        memory: 128Mi
      limits:
        cpu: 300m
        memory: 128Mi

global:
  k8sIngress:
    enabled: false
    enableHttps: true
    gatewayName: istio-ingressgateway
  proxy:
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 500m
        memory: 200Mi
  defaultResources:
    requests:
      cpu: 10m
      memory: 128Mi
    limits:
      cpu: 100m
      memory: 256Mi

certmanager:
  enabled: false
  email: cloudservices@liatr.io

grafana:
  enabled: true
  ingress:
    enabled: true
    annotations:
      kubernetes.io/ingress.class: "nginx"
      kubernetes.io/tls-acme: "true"
      nginx.ingress.kubernetes.io/ssl-redirect: "true"
      nginx.ingress.kubernetes.io/rewrite-target: "/"
      certmanager.k8s.io/issuer: "letsencrypt-dns"
    tls:
    - hosts:
      - ${domain}
      secretName: istio-ingress-tls
    hosts:
    - ${domain}

kiali:
  enabled: true
  dashboard:
    auth:
      strategy: anonymous
    viewOnlyMode: true
    grafanaURL: https://${domain}/grafana
    jaegerURL: https://${domain}/jaeger
  ingress:
    enabled: true
    annotations:
      kubernetes.io/ingress.class: "nginx"
      kubernetes.io/tls-acme: "true"
      nginx.ingress.kubernetes.io/ssl-redirect: "true"
      certmanager.k8s.io/issuer: "letsencrypt-dns"
    tls:
    - hosts:
      - ${domain}
      secretName: istio-ingress-tls
    hosts:
    - ${domain}

tracing:
  enabled: true
  ingress:
    enabled: true
    annotations:
      kubernetes.io/ingress.class: "nginx"
      kubernetes.io/tls-acme: "true"
      nginx.ingress.kubernetes.io/ssl-redirect: "true"
      certmanager.k8s.io/issuer: "letsencrypt-dns"
    tls:
    - hosts:
      - ${domain}
      secretName: istio-ingress-tls
    hosts:
    - ${domain}
  jaeger:
    resources:
      requests:
        cpu: 100m
        memory: 1Gi
      limits:
        cpu: 500m
        memory: 2Gi

prometheus:
  resources:
    requests:
      cpu: 200m
      memory: 2Gi
    limits:
      cpu: 1
      memory: 5Gi

galley:
  resources:
    requests:
      cpu: 50m
      memory: 128Mi
    limits:
      cpu: 200m
      memory: 256Mi
pilot:
  maxReplicas: 10
  resources:
    requests:
      cpu: 10m
      memory: 64Mi
    limits:
      cpu: 500m
      memory: 512Mi
mixer:
  telemetry:
    resources:
      requests:
        cpu: 10m
        memory: 128Mi
      limits:
        cpu: 100m
        memory: 256Mi
security:
  resources:
    requests:
      cpu: 20m
      memory: 128Mi
    limits:
      cpu: 400m
      memory: 256Mi
