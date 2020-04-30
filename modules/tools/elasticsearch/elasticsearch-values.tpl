%{~ if !local }
replicas: ${replicas}
volumeClaimTemplate:
  %{~ if k8s_storage_class != "" ~}
  storageClassName: ${k8s_storage_class}
  %{~ endif ~}
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
secretMounts:
  - name: ${elasticsearch_certs_secret_name}
    secretName: ${elasticsearch_certs_secret_name}
    path: /usr/share/elasticsearch/config/certs
