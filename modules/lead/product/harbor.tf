data "kubernetes_secret" "product-harbor-creds" {
  provider = kubernetes.toolchain
  metadata {
    name      = "${var.product-name}-harbor-credentials"
    namespace = "toolchain"
  }
}
