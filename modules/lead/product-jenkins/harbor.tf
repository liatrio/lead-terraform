data "kubernetes_secret" "product-harbor-creds" {
  count = var.enable_harbor ? 1 : 0
  provider = kubernetes.toolchain
  metadata {
    name      = "${var.product_name}-harbor-credentials"
    namespace = "toolchain"
  }
}

// harbor project

// harbor robot account

// kuberentes secret "${var.product_name}-harbor-credentials" with robot account creds
