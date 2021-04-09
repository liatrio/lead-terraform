data "vault_generic_secret" "github_creds" {
  count = var.jenkins_pipeline_source == "github" ? 1 : 0
  path  = "lead/aws/${data.aws_caller_identity.current.account_id}/github"
}

resource "kubernetes_secret" "github_creds" {
  count = var.jenkins_pipeline_source == "github" ? 1 : 0

  metadata {
    name      = "github-credentials"
    namespace = module.toolchain_namespace.name
  }

  data = {
    username = data.vault_generic_secret.github_creds[0].data["username"]
    token    = data.vault_generic_secret.github_creds[0].data["token"]
  }
}
