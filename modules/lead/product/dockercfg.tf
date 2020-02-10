locals {
  artifactory_user = length(data.kubernetes_secret.jenkins_artifactory_credential[0]) ? data.kubernetes_secret.jenkins_artifactory_credential[0].data.username : ""
  artifactory_pass = length(data.kubernetes_secret.jenkins_artifactory_credential[0]) ? data.kubernetes_secret.jenkins_artifactory_credential[0].data.password : ""
  harbor_pass      = length(data.kubernetes_secret.product-harbor-creds[0]) ? data.kubernetes_secret.product-harbor-creds[0].data.AUTH : ""
}

data "template_file" "dockercfg" {
  template = file("${path.module}/dockercfg.tpl")
 
  vars = { 
    email = "jenkins@liatr.io"
    artifactory_url   = "https://artifactory.toolchain.${var.cluster_domain}/docker-registry/${var.product_name}"
    artifactory_auth = base64encode(
      "${local.artifactory_user}:${local.artifactory_pass}",
    )   
    harbor_url = "https://harbor.toolchain.${var.cluster_domain}/${var.product_name}"
    harbor_auth = base64encode(
      "robot$imagepusher:${local.harbor_pass}",
    )   
    enable_harbor = var.enable_harbor
  }
}

resource "kubernetes_secret" "jenkins_repository_dockercfg" {
  provider = kubernetes.toolchain
  metadata {
    name      = "jenkins-repository-dockercfg"
    namespace = module.toolchain_namespace.name
  }
 
  data = { 
    "config.json" = data.template_file.dockercfg.rendered
  }
 
  type = "Opaque"
}
