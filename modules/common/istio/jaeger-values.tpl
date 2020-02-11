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
      memory: 1.5Gi
    limits:
      cpu: 1
      memory: 3Gi
  livenessProbe:
    failureThreshold: 5
  readinessProbe:
    initialDelay: 30
    failureThreshold: 12
global:
  defaultResources:
    requests:
      cpu: 10m
      memory: 128Mi
    limits:
      cpu: 100m
      memory: 128Mi
