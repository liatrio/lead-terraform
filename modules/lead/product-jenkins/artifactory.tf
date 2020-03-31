data "kubernetes_secret" "jenkins_artifactory_credential" {
  count    = var.enable_artifactory ? 1 : 0
  provider = kubernetes.toolchain
  metadata {
    name      = "jenkins-artifactory-credential"
    namespace = "toolchain"
  }
}

data "template_file" "maven_settings" {
  count    = var.enable_artifactory ? 1 : 0
  template = file("${path.module}/artifactory-maven-settings.tpl")

  vars = {
    username = data.kubernetes_secret.jenkins_artifactory_credential[0].data.username
    password = data.kubernetes_secret.jenkins_artifactory_credential[0].data.password
  }
}

resource "kubernetes_secret" "jenkins_artifactory_maven_settings" {
  count    = var.enable_artifactory ? 1 : 0
  provider = kubernetes.toolchain
  metadata {
    name      = "jenkins-artifactory-maven-settings"
    namespace = module.toolchain_namespace.name
  }

  data = {
    "settings.xml" = data.template_file.maven_settings[0].rendered
  }

  type = "Opaque"
}

