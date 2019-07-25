
data "template_file" "mailhog_values" {
  template = file("${path.module}/mailhog-values.tpl")

  vars = {
    ssl_redirect     = var.root_zone_name == "localhost" ? false : true
    ingress_hostname = "mailhog.${module.toolchain_namespace.name}.${var.cluster}.${var.root_zone_name}"
    smtp_json        = jsonencode(var.smtp_json)
  }
}

resource "helm_release" "mailhog" {
  count      = var.enable_mailhog ? 1 : 0
  repository = data.helm_repository.codecentric.metadata[0].name
  name       = "mailhog"
  namespace  = module.toolchain_namespace.name
  chart      = "mailhog"
  version    = "3.0.0"
  timeout    = 1200

  values = [data.template_file.mailhog_values.rendered]
}

