data "kubernetes_secret" "jenkins_artifactory_credential" {
  provider = kubernetes.toolchain
  metadata {
    name      = "jenkins-artifactory-credential"
    namespace = "toolchain"
  }
}

data "template_file" "maven_settings" {
  template = file("${path.module}/artifactory-maven-settings.tpl")

  vars = {
    username = data.kubernetes_secret.jenkins_artifactory_credential.data.username
    password = data.kubernetes_secret.jenkins_artifactory_credential.data.password
  }
}

resource "kubernetes_secret" "jenkins_artifactory_maven_settings" {
  metadata {
    name      = "jenkins-artifactory-maven-settings"
    namespace = module.toolchain_namespace.name
  }

  data = {
    "settings.xml" = data.template_file.maven_settings.rendered
  }

  type = "Opaque"
}

