data "template_file" "dashboard_values" {
  template = "${file("${path.module}/dashboard-values.tpl")}"

  vars = {
    cluster_domain = "${var.namespace}.${var.cluster}.${var.root_zone_name}"
  }
}

data "helm_repository" "liatrio" {
  name = "liatrio"
  url  = "https://artifactory.liatr.io/artifactory/helm/"
}

resource "helm_release" "lead-dashboard" {
  repository = "${data.helm_repository.liatrio.metadata.0.name}"
  name       = "lead-dashboard"
  namespace  = "${var.namespace}"
  chart      = "lead-dashboard"
  version    = "${var.dashboard_version}"
  timeout    = 900

  values = ["${data.template_file.dashboard_values.rendered}"]
}

resource "kubernetes_secret" "auth_tokens" {
  metadata {
    name      = "auth-tokens"
    namespace = "${var.namespace}"
  }

  data {
    JIRA_TOKEN      = "${var.jira_token}"
    BITBUCKET_TOKEN = "${var.bitbucket_token}"
  }
}
