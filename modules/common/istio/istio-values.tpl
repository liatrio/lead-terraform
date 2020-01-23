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
        memory: 64Mi
      limits:
        cpu: 1000m
        memory: 256Mi

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
  contextPath: "/"
  ingress:
    enabled: true
    image:
      repository: grafana/grafana
      tag: 6.5.1-ubuntu
    annotations:
      kubernetes.io/ingress.class: "toolchain-nginx"
      nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
      nginx.ingress.kubernetes.io/rewrite-target: "/"
    tls:
    - hosts:
      - istio-grafana.${domain}
    hosts:
    - istio-grafana.${domain}
  resources:
    requests:
      cpu: 10m
      memory: 64Mi
    limits:
      cpu: 250m
      memory: 128Mi

kiali:
  enabled: false

tracing:
  enabled: true
  contextPath: "/"
  ingress:
    enabled: true
    annotations:
      kubernetes.io/ingress.class: "toolchain-nginx"
      nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    tls:
    - hosts:
      - jaeger.${domain}
    hosts:
    - jaeger.${domain}
  jaeger:
    hub: docker.io/jaegertracing
    image: all-in-one
    tag: 1.16
    memory:
      max_traces: 50000
    spanStorageType: badger
    persist: true
    storageClassName: ${k8s_storage_class}
    accessMode: ReadWriteOnce
    resources:
      requests:
        cpu: 200m
        memory: 800Mi
      limits:
        cpu: 1
        memory: 3Gi

prometheus:
  resources:
    requests:
      cpu: 200m
      memory: 1.5Gi
    limits:
      cpu: 800m
      memory: 5Gi

galley:
  resources:
    requests:
      cpu: 20m
      memory: 32Mi
    limits:
      cpu: 200m
      memory: 128Mi
pilot:
  traceSampling: ${pilotTraceSampling}
  autoscaleMax: 20
  resources:
    requests:
      cpu: 500m
      memory: 500Mi
    limits:
      cpu: 1.3
      memory: 1Gi
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
      memory: 32Mi
    limits:
      cpu: 1
      memory: 128Mi

sidecarInjectorWebhook:
  resources:
    requests:
      cpu: 100m
      memory: 16Mi
    limits:
      cpu: 400m
      memory: 64Mi
