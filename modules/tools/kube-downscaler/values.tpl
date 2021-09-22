rbac:
  create: true
image:
  args:
    %{~ if excluded_namespaces != "" ~}
    - --exclude-namespaces=${excluded_namespaces}
    %{~ endif ~}
    - --exclude-deployments=kube-downscaler,metrics-server,cluster-autoscaler-aws-cluster-autoscaler
    - --default-uptime=${uptime}
    - --include-resources=deployments,statefulsets
resources:
  limits:
    cpu: 700m
    memory: 100Mi
  requests:
    cpu: 10m
    memory: 30Mi
