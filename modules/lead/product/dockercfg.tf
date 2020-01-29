data "template_file" "dockercfg" {
  template = file("${path.module}/dockercfg.tpl")
 
  vars = { 
    email = "jenkins@liatr.io"
    artifactory_url   = "https://artifactory.toolchain.${var.cluster_domain}/docker-registry/${var.product_name}"
    artifactory_auth = base64encode(
      "${data.kubernetes_secret.jenkins_artifactory_credential.data.username}:${data.kubernetes_secret.jenkins_artifactory_credential.data.password}",
    )   
    harbor_url = "https://harbor.toolchain.${var.cluster_domain}/${var.product_name}"
    harbor_auth = base64encode(
      "robot$$${var.product-name}:${data.kubernetes_secret.product-harbor-creds.data.AUTH}",
    )   
  }
}

resource "kubernetes_secret" "jenkins_repository_dockercfg" {
  metadata {
    name      = "jenkins-repository-dockercfg"
    namespace = module.toolchain_namespace.name
  }
 
  data = { 
    "config.json" = data.template_file.dockercfg.rendered
  }
 
  type = "Opaque"
}
