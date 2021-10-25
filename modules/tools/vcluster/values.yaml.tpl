syncer:
  extraArgs:
    - --tls-san=${vcluster_hostname}
    - --out-kube-config-server=https://${vcluster_hostname}

vcluster:
  extraArgs:
    - --service-cidr=${host_cluster_service_ip_cidr}
