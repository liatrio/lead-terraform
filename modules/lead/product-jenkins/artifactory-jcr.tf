data "kubernetes_secret" "artifactory_jcr_credentials" {
  count    = var.enable_artifactory_jcr ? 1 : 0
  provider = kubernetes.toolchain
  metadata {
    name      = "artifactory_jcr_credentials"
    namespace = "toolchain"
  }
}