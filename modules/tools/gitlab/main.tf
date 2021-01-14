module "gitlab_namespace" {
  source = "../../common/namespace"

  resource_limit_cpu = "1"
  resource_limit_memory = "4G"

  namespace = "gitlab"
}

resource "helm_release" "gitlab" {
  count = var.enable_gitlab ? 1 : 0

  name       = "gitlab"
  repository = "https://charts.gitlab.io/"
  chart      = "gitlab"
  version    = "4.7.4"
  namespace  = module.gitlab_namespace.name
  wait       = true

  values = [
    templatefile("${path.module}/gitlab-values.tpl", {
      gitlab_fqdn              = "toolchain.${var.root_domain}"
      certmanager_issuer_email = var.certmanager_issuer_email
    })
  ]
}
