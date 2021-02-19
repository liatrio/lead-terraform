module "database_namespace" {
  source      = "../../common/namespace"
  namespace   = "${var.product_name}-db"
  labels      = {
    "istio-injection"                        = "enabled"
    "appmesh.k8s.aws/sidecarInjectorWebhook" = "enabled"
  }
  annotations = {
    name                                 = "${var.product_name}-db"
    "opa.lead.liatrio/ingress-whitelist" = "*.${var.product_name}-db.${var.cluster_domain}"
    "opa.lead.liatrio/image-whitelist"   = var.image_whitelist
  }

  providers = {
    helm       = helm.system
    kubernetes = kubernetes.system
  }
}

resource "random_password" "mongodb_root_password" {
  length  = 8
  special = false
}

resource "helm_release" "mongodb" {
  provider   = helm.system
  name       = "mongodb"
  namespace  = module.database_namespace.name
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "mongodb"
  version    = "8.3.2"
  timeout    = 600
  wait       = true

  values = [
    templatefile("${path.module}/mongo.tpl", {
      mongodbRootPassword = random_password.mongodb_root_password.result
    })
  ]
}

# wait for db to be ready
locals {
  ready = <<EOF
until mongo mongodb:27017 --disableImplicitSessions --eval 'db.serverStatus()'; do
  sleep 3
done
EOF
}

resource "kubernetes_job" "wait_for_db" {
  metadata {
    name = "wait-for-db"
    namespace  = module.database_namespace.name

    annotations = {
      "sidecar.istio.io/inject" = "false"
    }
  }
  spec {
    template {
      metadata {
        annotations = {
          "sidecar.istio.io/inject" = "false"
        }
      }
      spec {
        container {
          name    = "mongodb"
          image   = "bitnami/mongodb:4.2.9-debian-10-r0"
          command = [
            "bash",
            "-c",
            local.ready,
          ]
        }
        restart_policy = "Never"
      }
    }
    backoff_limit = 5
  }

  wait_for_completion = true

  timeouts {
    create = "5m"
  }

  depends_on = [
    helm_release.mongodb
  ]
}
