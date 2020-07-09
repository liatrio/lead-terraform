%{~ if !local }
replicas: ${replicas}
volumeClaimTemplate:
  %{~ if k8s_storage_class != "" ~}
  storageClassName: ${k8s_storage_class}
  %{~ endif ~}
  resources:
    requests:
      storage: ${disk_size}
resources:
  requests:
    cpu: 100m
    memory: 7.0Gi
  limits:
    cpu: 1000m
    memory: 7.5Gi

esJavaOpts: "-Xmx1024m -Xms1024m"
%{~ else }
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
  %{~ if k8s_storage_class != "" ~}
  storageClassName: ${k8s_storage_class}
  %{~ else ~}
  storageClassName: "hostpath"
  %{~ endif ~}
  resources:
    requests:
      storage: 100M
%{~ endif }

extraEnvs:
  - name: ELASTIC_USERNAME
    valueFrom:
      secretKeyRef:
        name: ${elasticsearch_credentials_secret_name}
        key: username
  - name: ELASTIC_PASSWORD
    valueFrom:
      secretKeyRef:
        name: ${elasticsearch_credentials_secret_name}
        key: password

secretMounts:
  - name: ${elasticsearch_certs_secret_name}
    secretName: ${elasticsearch_certs_secret_name}
    path: /usr/share/elasticsearch/config/certs

protocol: https

esConfig:
  elasticsearch.yml: |
    xpack.security.http.ssl.enabled: true
    xpack.security.http.ssl.key:  /usr/share/elasticsearch/config/certs/tls.key
    xpack.security.http.ssl.certificate: /usr/share/elasticsearch/config/certs/tls.crt
    xpack.security.http.ssl.certificate_authorities: [ "/usr/share/elasticsearch/config/certs/ca.crt" ]
