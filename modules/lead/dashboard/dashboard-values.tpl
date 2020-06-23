grafana:
  ingress:
    annotations:
      kubernetes.io/ingress.class: "toolchain-nginx"
      nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    tls:
    - hosts:
      - grafana.${cluster_domain}
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

