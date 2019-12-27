data "kubernetes_secret" "harbor-harbor-core" {
  provider = kubernetes.toolchain
  metadata {
    name      = "harbor-harbor-core"
    namespace = "toolchain"
  }
}

data "template_file" "harbor_cfg" {
  template = file("${path.module}/artifactory-dockercfg.tpl")

  vars = {
    url   = "https://harbor.toolchain.${var.cluster_domain}/docker-registry/${var.product_name}"
    email = "jenkins@liatr.io"
    auth = base64encode(
      "admin:${data.kubernetes_secret.harbor-harbor-core.data.HARBOR_ADMIN_PASSWORD}",
    )
  }
}

resource "kubernetes_secret" "jenkins_harbor_cfg" {
  metadata {
    name      = "jenkins-harbor-cfg"
    namespace = module.toolchain_namespace.name
  }

  data = {
    "harbor_config.json" = data.template_file.harbor_cfg.rendered
  }

  type = "Opaque"
}
