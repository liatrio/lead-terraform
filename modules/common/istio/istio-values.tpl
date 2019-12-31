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
        cpu: 10m
        memory: 32Mi
      limits:
        cpu: 40m
        memory: 64Mi
  defaultResources:
    requests:
      cpu: 10m
      memory: 32Mi
    limits:
      cpu: 100m
      memory: 64Mi

certmanager:
  enabled: false
  email: cloudservices@liatr.io

grafana:
  enabled: true
  ingress:
    enabled: true
    image:
      repository: grafana/grafana
      tag: 6.5.1-ubuntu
    annotations:
      kubernetes.io/ingress.class: "nginx"
      kubernetes.io/tls-acme: "true"
      acme.cert-manager.io/http01-edit-in-place: "true"
      nginx.ingress.kubernetes.io/ssl-redirect: "true"
      nginx.ingress.kubernetes.io/rewrite-target: "/"
      cert-manager.io/issuer: "letsencrypt-dns"
    tls:
    - hosts:
      - ${domain}
      secretName: istio-ingress-tls
    hosts:
    - ${domain}
  resources:
    requests:
      cpu: 16m
      memory: 64Mi
    limits:
      cpu: 64m
      memory: 128Mi

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
      acme.cert-manager.io/http01-edit-in-place: "true"
      nginx.ingress.kubernetes.io/ssl-redirect: "true"
      cert-manager.io/issuer: "letsencrypt-dns"
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
      acme.cert-manager.io/http01-edit-in-place: "true"
      nginx.ingress.kubernetes.io/ssl-redirect: "true"
      cert-manager.io/issuer: "letsencrypt-dns"
    tls:
    - hosts:
      - ${domain}
      secretName: istio-ingress-tls
    hosts:
    - ${domain}
  jaeger:
    resources:
      requests:
        cpu: 10m
        memory: 400Mi
      limits:
        cpu: 25m
        memory: 600Mi

prometheus:
  resources:
    requests:
      cpu: 200m
      memory: 2Gi
    limits:
      cpu: 500m
      memory: 4Gi

galley:
  resources:
    requests:
      cpu: 32m
      memory: 64Mi
    limits:
      cpu: 128m
      memory: 128Mi
pilot:
  traceSampling: ${pilotTraceSampling}
  autoscaleMax: 20
  resources:
    requests:
      cpu: 20m
      memory: 96Mi
    limits:
      cpu: 80m
      memory: 192Mi
  global:
    proxy:
      resource:
        requests:
          cpu: 5m
          memory: 32Mi
        limits:
          cpu: 20m
          memory: 64Mi
mixer:
  telemetry:
    loadshedding: 
      mode: logonly
    autoscaleMax: 20
    resources:
      requests:
        cpu: 64m
        memory: 64Mi
      limits:
        cpu: 128m
        memory: 128Mi
security:
  resources:
    requests:
      cpu: 20m
      memory: 128Mi
    limits:
      cpu: 400m
      memory: 256Mi

sidecarInjectorWebhook:
  resources:
    requests:
      cpu: 15m
      memory: 16Mi
    limits:
      cpu: 25m
      memory: 64Mi

security:
  resources:
    requests:
      cpu: 2m
      memory: 32Mi
    limits:
      cpu: 100m
      memory: 64Mi
