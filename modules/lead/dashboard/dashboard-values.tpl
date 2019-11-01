elasticsearch:
  volumeClaimTemplate:
    storageClassName: gp2
  resources:
    requests:
      cpu: 100m
      memory: 2Gi
    limits:
      cpu: 500m
      memory: 3.5Gi
kibana:
  resources:
    requests:
      cpu: 20m
      memory: 400Mi
    limits:
      cpu: 200m
      memory: 600Mi
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
    resources:
      requests:
        cpu: 10m
        memory: 100Mi
      limits:
        cpu: 100m
        memory: 150Mi
logstash:
  logstashJavaOpts: "-Djava.security.egd=file:/dev/urandom"
  resources:
    requests:
      cpu: 10m
      memory: 600Mi
    limits:
      cpu: 400m
      memory: 1.1Gi
logstash-jenkins:
  logstashJavaOpts: "-Djava.security.egd=file:/dev/urandom"
  resources:
    requests:
      cpu: 10m
      memory: 500Gi
    limits:
      cpu: 400m
      memory: 1.5Gi

