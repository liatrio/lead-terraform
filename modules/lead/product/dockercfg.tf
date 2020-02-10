data "template_file" "multi_dockercfg" {
  count = var.enable_harbor ? 1 : 0
  template = file("${path.module}/dockercfg.tpl")
 
  vars = { 
    email = "jenkins@liatr.io"
    artifactory_url   = "https://artifactory.toolchain.${var.cluster_domain}/docker-registry/${var.product_name}"
    artifactory_auth = base64encode(
      "${data.kubernetes_secret.jenkins_artifactory_credential[0].data.username}:${data.kubernetes_secret.jenkins_artifactory_credential[0].data.password}",
    )   
    harbor_url = "https://harbor.toolchain.${var.cluster_domain}/${var.product_name}"
    harbor_auth = base64encode(
      "robot$imagepusher:${data.kubernetes_secret.product-harbor-creds[0].data.AUTH}",
    )   
    enable_harbor = var.enable_harbor
  }
}

data "template_file" "artifactory_dockercfg" {
  count = var.enable_harbor ? 0 : 1
  template = file("${path.module}/dockercfg.tpl")

  vars = {
    email = "jenkins@liatr.io"
    artifactory_url   = "https://artifactory.toolchain.${var.cluster_domain}/docker-registry/${var.product_name}"
    artifactory_auth = base64encode(
      "${data.kubernetes_secret.jenkins_artifactory_credential[0].data.username}:${data.kubernetes_secret.jenkins_artifactory_credential[0].data.password}",
    )
    enable_harbor = var.enable_harbor
  }
}

resource "kubernetes_secret" "jenkins_repository_dockercfg" {
  metadata {
    name      = "jenkins-repository-dockercfg"
    namespace = module.toolchain_namespace.name
  }
 
  data = { 
    "config.json" = var.enable_harbor ? data.template_file.multi_dockercfg[0].rendered : data.template_file.artifactory_dockercfg[0].rendered
  }
 
  type = "Opaque"
}
