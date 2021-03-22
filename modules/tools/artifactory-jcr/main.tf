provider "kubernetes" {
  config_path = "~/.kube/config"
  config_context = "docker-desktop"
}
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}
resource "helm_release" "artifactory_jcr" {
  repository = "https://repo.chartcenter.io"
  name       = "jfrog-container-registry"
  namespace  = var.namespace
  chart      = "jfrog/artifactory-jcr"
  version    = "3.6.0"

  values = [
    templatefile("${path.module}/values.yaml.tpl", {
      artifactory_jcr_hostname = var.artifactory_jcr_hostname
      jcr_admin_password = var.jcr_admin_password
      ingress_enabled = false
      postgres_admin_password = var.postgres_admin_password
    })
  ]
}
