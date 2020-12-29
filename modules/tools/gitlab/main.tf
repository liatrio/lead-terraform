resource "helm_release" "gitlab" {
  count = var.enable_gitlab ? 1 : 0

  name       = "gitlab"
  repository = "https://charts.gitlab.io/"
  chart      = "gitlab"
  namespace  = var.namespace

  values = [
    template_file("${path.module}/gitlab-values.tpl", {
      gitlab_fqdn              = "gitlab.${var.root_domain}"
      certmanager_issuer_email = var.certmanager_issuer_email
    })
  ]
}
