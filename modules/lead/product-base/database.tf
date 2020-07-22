module "database_namespace" {
  source    = "../../common/namespace"
  namespace = "${var.product_name}-db"
  labels = {
    "istio-injection"                        = "enabled"
    "appmesh.k8s.aws/sidecarInjectorWebhook" = "enabled"
  }
  annotations = {
    name                                                     = "${var.product_name}-db"
    "opa.lead.liatrio/ingress-whitelist"                     = "*.${var.product_name}-db.${var.cluster_domain}"
    "opa.lead.liatrio/image-whitelist"                       = var.image_whitelist
    "vault.hashicorp.com/agent-inject"                       = "true"
    "vault.hashicorp.com/role"                               = "${var.product-name}-mongodb"
    "vault.hashicorp.com/agent-inject-secret-mongodb.json"   = "database/creds/${var.product_name}-mongodb"
    "vault.hashicorp.com/agent-inject-template-mongodb.json" = <<EOF
  {{- with secret "database/creds/${var.product_name}-mongodb" -}}
  {
    "username": "{{ .Data.username }}",
    "password": "{{ .Data.password }}"
  }
  {{- end }}
EOF
  }

  providers = {
    helm       = helm.system
    kubernetes = kubernetes.system
  }
}

data "helm_repository" "bitnami" {
  name = "bitnami"
  url  = "https://charts.bitnami.com/bitnami"
}

data "template_file" "mongo_values" {
  template = file("${path.module}/mongo.tpl")
}

resource "helm_release" "mongodb" {
  provider   = helm.system
  name       = "mongodb"
  namespace  = module.database_namespace.name
  repository = data.helm_repository.bitnami.name
  chart      = "bitnami/mongodb"
  version    = "7.14.8"
  timeout    = 600
  wait       = true

  values = [data.template_file.mongo_values.rendered]
}
