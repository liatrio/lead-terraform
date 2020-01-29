resource "helm_release" "k8s_spot_termination_handler" {
  count      = var.enable_k8s_spot_termination_handler ? 1 : 0
  repository = data.helm_repository.stable.metadata[0].name
  chart      = "k8s-spot-termination-handler"
  version    = "1.4.3"
  namespace  = "kube-system"
  name       = "k8s-spot-termination-handler"
  timeout    = 600

  values     = [<<EOF
nodeSelector:
  kubernetes.io/lifecycle: preemptible
resources:
  limits:
    cpu: 10m
    memory: 64Mi
  requests:
    cpu: 1m
    memory: 16Mi
priorityClassName: system-node-critical
EOF
  ]
}
