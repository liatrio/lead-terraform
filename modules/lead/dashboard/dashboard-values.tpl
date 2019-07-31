elasticsearch:
  volumeClaimTemplate:
    storageClassName: gp2
  resources:
    requests:
      cpu: 50m
      memory: 2Gi
    limits:
      cpu: 500m
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
      cpu: 50m
      memory: 100Mi
    limits:
      cpu: 500m
      memory: 200Mi
  sidecar:
    dashboards:
      searchNamespace: ${namespace}
logstash:
  logstashJavaOpts: "-Djava.security.egd=file:/dev/urandom"
  resources:
    requests:
      cpu: 200m
      memory: 512Mi
    limits:
      cpu: 400m
      memory: 1024Mi
logstash-jenkins:
  logstashJavaOpts: "-Djava.security.egd=file:/dev/urandom"
  resources:
    requests:
      cpu: 200m
      memory: 512Mi
    limits:
      cpu: 400m
      memory: 1024Mi
