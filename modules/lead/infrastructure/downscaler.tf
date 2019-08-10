data "helm_repository" "liatrio" {
  name = "liatrio"
  url  = "https://artifactory.liatr.io/artifactory/helm/"
}

resource "helm_release" "kube_downscaler" {
  repository = data.helm_repository.liatrio.metadata[0].name
  name       = "kube-downscaler"
  namespace  = var.namespace
  chart      = "kube-downscaler"
  version    = "0.1.0"
  timeout    = 900
  values     = [<<EOF
image:
  args: "--exclude-namespaces=kube-system,${var.namespace} --default-uptime=\"${var.uptime}\""
EOF
  ]
}
