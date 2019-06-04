elasticsearch:
  volumeClaimTemplate:
    storageClassName: gp2
grafana:
  ingress:
    hosts:
    - grafana.${cluster_domain}
  rbac:
    pspEnabled: false
    namespaced: true