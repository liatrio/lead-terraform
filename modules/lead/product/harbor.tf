data "kubernetes_secret" "product-harbor-creds" {
  provider = kubernetes.toolchain
  metadata {
    name      = "${var.product_name}-harbor-credentials"
    namespace = "toolchain"
  }
}
