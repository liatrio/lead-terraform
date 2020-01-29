data "helm_repository" "liatrio" {
  name = "liatrio"
  url  = "https://artifactory.liatr.io/artifactory/helm/"
}

locals {
  downscaler_values = <<EOF
rbac:
  create: true
image:
  args:
  - --exclude-namespaces=${join(",",var.downscaler_exclude_namespaces)}
  - --exclude-deployments=kube-downscaler,metrics-server,cluster-autoscaler-aws-cluster-autoscaler
  - --default-uptime=${var.uptime}
  - --include-resources=deployments,statefulsets
resources:
  limits:
    cpu: 700m
    memory: 100Mi
  requests:
    cpu: 10m
    memory: 30Mi
EOF
}

resource "helm_release" "kube_downscaler" {
  count      = var.enable_downscaler ? 1 : 0
  repository = data.helm_repository.liatrio.metadata[0].name
  name       = "kube-downscaler"
  namespace  = var.namespace
  chart      = "kube-downscaler"
  version    = "0.1.0"
  timeout    = 900
  values     = [var.essential_toleration_values, local.downscaler_values]
}
