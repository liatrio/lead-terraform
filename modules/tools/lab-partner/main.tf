data "helm_repository" "liatrio" {
  name = "liatrio"
  url  = "https://liatrio-helm.s3.us-east-1.amazonaws.com/charts"
}

data "template_file" "lab_partner_values" {
  template = file("${path.module}/lab-partner-values.tpl")

  vars = {
    namespace = var.namespace
    cluster_domain  = "${var.cluster}.${var.root_zone_name}"

    slack_bot_token = var.slack_bot_token
    slack_client_signing_secret = var.slack_client_signing_secret
    team_id = var.team_id
  }
}

resource "helm_release" "lab_partner" {
  count      = var.enable_lab_partner ? 1 : 0
  repository = data.helm_repository.liatrio.metadata[0].name
  timeout    = 120
  name       = "lab-partner"
  chart      = "lab-partner"
  version    = var.lab_partner_version
  namespace  = var.namespace

  values = [
    data.template_file.lab_partner_values.rendered
  ]
}

