elasticsearch:
%{ if local == "false" }
  replicas: ${elasticsearch_replicas}
  volumeClaimTemplate:
    storageClassName: ${k8s_storage_class}
    resources:
      requests:
        storage: 15Gi
  resources:
    requests:
      cpu: 100m
      memory: 3.5Gi
    limits:
      cpu: 1000m
      memory: 7.5Gi

  esJavaOpts: "-Xmx1024m -Xms1024m"
%{ else }
  # Permit co-located instances for solitary minikube virtual machines.
  antiAffinity: "soft"

  # Shrink default JVM heap.
  esJavaOpts: "-Xmx128m -Xms128m"

  # Allocate smaller chunks of memory per pod.
  resources:
    requests:
      cpu: "100m"
      memory: "512M"
    limits:
      cpu: "1000m"
      memory: "512M"

  # Request smaller persistent volumes.
  volumeClaimTemplate:
    accessModes: [ "ReadWriteOnce" ]
    storageClassName: "hostpath"
    resources:
      requests:
        storage: 100M
%{ endif }
  secretMounts:
  - name: ${elasticsearch-certs}
    secretName: ${elasticsearch-certs}
    path: /usr/share/elasticsearch/config/certs

kibana:
  secretMounts:
  - name: ${elasticsearch-certs}
    secretName: ${elasticsearch-certs}
    path: /usr/share/elasticsearch/config/certs
  resources:
    requests:
      cpu: 150m
      memory: 250Mi
    limits:
      cpu: 500m
      memory: 800Mi
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
fluent-bit:
  resources:
    requests:
      cpu: 30m
      memory: 25Mi
    limits:
      cpu: 500m
      memory: 50Mi
  backend:
    type: es
    es:
      host: elasticsearch-master
      port: 9200
      type: _doc
      tls: "on"
      tls_verify: "off"
      tls_secret: ${elasticsearch-certs}
      tls_debug: 4
gatekeeperConfig:
  clientId: ${client-id}
  clientSecret: ${client-secret}
  discoveryUrl: ${discovery-url}
  listenPort: ${listen}
  upstreamUrl: ${upstream-url}
keycloak:
  enabled: ${keycloak-enabled}
  kibanaHostname: ${kibana-hostname}
  ingress:
    secretName: ${proxy-certs}
