resource "random_string" "anchore_admin_password" {
  length  = 10
  special = false
}

resource "random_string" "anchore_db_password" {
  length  = 10
  special = false
}

data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

resource "helm_release" "anchore-engine" {
  repository = "stable"
  name       = "anchore-engine"
  namespace  = "${module.toolchain_namespace.name}"
  chart      = "anchore-engine"
  version    = "1.0.4"
  timeout    = 900

  set {
    name  = "anchoreGlobal.existingSecret"
    value = "anchore-engine-credentials"
  }

  set_sensitive {
    name  = "postgresql.postgresPassword"
    value = "${random_string.anchore_db_password.result}"
  }
}

resource "kubernetes_secret" "anchore-engine-credentials" {
  metadata {
    name      = "anchore-engine-credentials"
    namespace = "${module.toolchain_namespace.name}"
  }

  data {
    "ANCHORE_ADMIN_PASSWORD" = "${random_string.anchore_admin_password.result}"
    "ANCHORE_DB_PASSWORD"    = "${random_string.anchore_db_password.result}"
  }
}

/*
data "helm_repository" "anchore-stable" {
    name = "anchore-stable"
    url  = "https://charts.anchore.io/stable"
}
resource "helm_release" "anchore-controller" {
  count = 0 # DISABLE THIS RELEASE
  repository = "anchore-stable"
  name       = "anchore-controller"
  namespace  = "${module.toolchain.namespace}"  
  chart      = "anchore-admission-controller"
  version    = "0.2.1"
  timeout    = 900

  set {
    name = "anchoreEndpoint"
    value = "http://anchore-engine-anchore-engine-api.${var.namespace}.svc.cluster.local:8228/v1/"
  }
  set {
    name = "credentialsSecret"
    value = "anchore-controller-credentials"
  }
}

resource "kubernetes_secret" "anchore-contoller-credentials" {
  metadata {
    name = "anchore-controller-credentials"
    namespace  = "${module.toolchain.namespace}"  
  }

  data {
    "credentials.json" = <<EOF
{"users": [{ "username": "admin", "password": "${random_string.anchore_admin_password.result}"}]}
EOF
  }
}
*/

