elasticsearch:
%{ if local == "false" }
  volumeClaimTemplate:
    storageClassName: ${k8s_storage_class}
  resources:
    requests:
      cpu: 100m
      memory: 2Gi
    limits:
      cpu: 500m
      memory: 3.5Gi
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
      acme.cert-manager.io/http01-edit-in-place: "true"
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

