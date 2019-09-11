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
  - --exclude-namespaces=kube-system
  - --exclude-deployments=kube-downscaler,metrics-server,cluster-autoscaler-aws-cluster-autoscaler
  - --default-uptime=${var.uptime}
  - --include-resources=deployments,statefulsets
EOF
}

resource "helm_release" "kube_downscaler" {
  repository = data.helm_repository.liatrio.metadata[0].name
  name       = "kube-downscaler"
  namespace  = var.namespace
  chart      = "kube-downscaler"
  version    = "0.1.0"
  timeout    = 900
  values     = [var.essential_toleration_values, local.downscaler_values] 
}
