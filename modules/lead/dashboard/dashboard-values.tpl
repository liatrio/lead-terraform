elasticsearch:
  volumeClaimTemplate:
    storageClassName: gp2
  resources:
    requests:
      cpu: 10m
      memory: 1.5Gi
    limits:
      cpu: 100m
      memory: 3Gi

grafana:
  ingress:
    annotations:
      kubernetes.io/ingress.class: "nginx"
      kubernetes.io/tls-acme: "true"
      nginx.ingress.kubernetes.io/ssl-redirect: "true"
    tls:
    - hosts:
      - grafana.${cluster_domain}
      secretName: grafana-ingress-tls
    hosts:
    - grafana.${cluster_domain}
  rbac:
    pspEnabled: false
    namespaced: true
  resources:
    requests:
      cpu: 10m
      memory: 100Mi
    limits:
      cpu: 100m
      memory: 150Mi
  sidecar:
    dashboards:
      searchNamespace: ${namespace}
logstash:
  logstashJavaOpts: "-Djava.security.egd=file:/dev/urandom"
  resources:
    requests:
      cpu: 10m
      memory: 500Mi
    limits:
      cpu: 400m
      memory: 1.5Gi
logstash-jenkins:
  logstashJavaOpts: "-Djava.security.egd=file:/dev/urandom"
  resources:
    requests:
      cpu: 10m
      memory: 500Gi
    limits:
      cpu: 400m
      memory: 1.5Gi

