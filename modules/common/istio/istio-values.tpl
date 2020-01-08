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
          cpu: 100m
          memory: 128Mi
        limits:
          cpu: 1000m
          memory: 512Mi
      token:
        aud: istio-ca
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 1000m
        memory: 512Mi

global:
  k8sIngress:
    enabled: false
    enableHttps: true
    gatewayName: istio-ingressgateway
  proxy:
    init:
      resources:
        limits:
          cpu: 100m
          memory: 50Mi
        requests:
          cpu: 10m
          memory: 10Mi
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 1000m
        memory: 512Mi
    protocolDetectionTimeout: 100ms
  defaultResources:
    requests:
      cpu: 10m
      memory: 128Mi
    limits:
      cpu: 100m
      memory: 128Mi

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
  resources:
    requests:
      cpu: 100m
      memory: 128Mi
    limits:
      cpu: 200m
      memory: 256Mi

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
    hub: docker.io/jaegertracing
    image: all-in-one
    tag: 1.16
    resources:
      requests:
        cpu: 256m
        memory: 400Mi
      limits:
        cpu: 512m
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
      cpu: 500m
      memory: 2048Mi
    limits:
      cpu: 1000m
      memory: 4096Mi
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
        cpu: 500m
        memory: 512Mi
      limits:
        cpu: 1000m
        memory: 1024Mi

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
      cpu: 100m
      memory: 16Mi
    limits:
      cpu: 400m
      memory: 64Mi
