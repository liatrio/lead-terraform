data "kubernetes_secret" "product-harbor-creds" {
  provider = kubernetes.toolchain
  metadata {
    name      = "${var.product-name}-harbor-credentials"
    namespace = "toolchain"
  }
}

data "template_file" "harbor_dockercfg" {
  template = file("${path.module}/artifactory-dockercfg.tpl")

  vars = {
    url   = "https:/harbor.toolchain.lead.sandbox.liatr.io"
    email = "jenkins@liatr.io"
    auth = base64encode(
      "robot$$${var.product-name}:${data.kubernetes_secret.product-harbor-creds.data.AUTH}",
    )
  }
}

resource "kubernetes_secret" "jenkins_harbor_dockercfg" {
  metadata {
    name      = "jenkins-harbor-dockercfg"
    namespace = module.toolchain_namespace.name
  }

  data = {
    "config.json" = data.template_file.harbor_dockercfg.rendered
  }

  type = "Opaque"
}
