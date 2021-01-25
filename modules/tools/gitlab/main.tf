module "gitlab_namespace" {
  source = "../../common/namespace"

  resource_limit_cpu    = "1"
  resource_limit_memory = "4G"

  namespace = "gitlab"
}

resource "helm_release" "gitlab" {
  name       = "gitlab"
  repository = "https://charts.gitlab.io/"
  chart      = "gitlab"
  version    = "4.7.4"
  namespace  = module.gitlab_namespace.name
  wait       = true

  values = [
    templatefile("${path.module}/gitlab-values.tpl", {
      gitlab_fqdn              = "toolchain.${var.root_domain}"
      ingress_class            = var.ingress_class
      cert_issuer              = var.cert_issuer
      certmanager_issuer_email = var.certmanager_issuer_email
    })
  ]
}
