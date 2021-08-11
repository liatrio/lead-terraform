module "istio_namespace" {
  source    = "../namespace"
  namespace = var.namespace
  annotations = {
    name = var.namespace
  }
  resource_max_cpu = "3"
}

resource "random_string" "kiali_admin_password" {
  length  = 10
  special = false
}

resource "kubernetes_secret" "kiali_dashboard_secret" {
  metadata {
    name      = "kiali"
    namespace = module.istio_namespace.name

    labels = {
      "app" = "kiali"
    }
  }

  type = "Opaque"

  data = {
    "username"   = var.kiali_username
    "passphrase" = random_string.kiali_admin_password.result
  }
}

resource "helm_release" "istio" {
  repository = "https://storage.googleapis.com/istio-release/releases/1.4.8/charts/"
  chart      = "istio"
  namespace  = module.istio_namespace.name
  name       = module.istio_namespace.name
  timeout    = 600
  wait       = true
  version    = "1.4.8"

  values = [
    templatefile("${path.module}/istio-values.tpl", {
      domain             = "${var.toolchain_namespace}.${var.cluster_domain}"
      pilotTraceSampling = var.pilot_trace_sampling
      k8s_storage_class  = var.k8s_storage_class
      ingress_class      = var.ingress_class

      jaeger_collector_hostname    = module.jaeger.jaeger_collector_internal_hostname
      jaeger_collector_zipkin_port = module.jaeger.jaeger_collector_zipkin_port
    })
  ]
}

module "istio_flagger" {
  source        = "../../common/flagger"
  namespace     = helm_release.istio.metadata[0].namespace
  event_webhook = var.flagger_event_webhook
}

resource "kubernetes_horizontal_pod_autoscaler" "kiali_autoscaler" {
  metadata {
    name      = "kiali"
    namespace = module.istio_namespace.name
  }
  spec {
    max_replicas                      = 10
    target_cpu_utilization_percentage = 60
    min_replicas                      = 2
    scale_target_ref {
      api_version = "apps/v1beta1"
      kind        = "Deployment"
      name        = "kiali"
    }
  }
}

resource "helm_release" "kiali" {
  chart     = "${path.module}/charts/kiali"
  namespace = module.istio_namespace.name
  name      = "kiali"
  timeout   = 600
  wait      = true

  set {
    name  = "domain"
    value = "${var.toolchain_namespace}.${var.cluster_domain}"
  }

  set {
    name  = "ingress.class"
    value = var.ingress_class
  }

  set {
    name  = "image"
    value = "quay.io/kiali/kiali:v1.9"
  }

  set {
    name  = "jaeger.query.internalHostname"
    value = module.jaeger.jaeger_query_internal_hostname
  }

  set {
    name  = "jaeger.query.externalHostname"
    value = module.jaeger.jaeger_query_external_hostname
  }

  set {
    name  = "jaeger.query.port"
    value = module.jaeger.jaeger_query_port
  }

  depends_on = [
    helm_release.istio
  ]
}

module "staging_app_wildcard" {
  source = "../certificates"

  name      = "staging-app-wildcard"
  namespace = module.istio_namespace.name
  domain    = "staging.apps.${var.cluster_domain}"

  issuer_name = var.issuer_name
  issuer_kind = var.issuer_kind
}

module "prod_app_wildcard" {
  source = "../certificates"

  name      = "prod-app-wildcard"
  namespace = module.istio_namespace.name
  domain    = "prod.apps.${var.cluster_domain}"

  issuer_name = var.issuer_name
  issuer_kind = var.issuer_kind
}

resource "helm_release" "app_gateway" {
  chart     = "${path.module}/charts/gateway"
  namespace = module.istio_namespace.name
  name      = "app-gateway"
  timeout   = 600
  wait      = true

  set {
    name  = "name"
    value = "app"
  }

  set {
    name  = "staging_host"
    value = "*.staging.apps.${var.cluster_domain}"
  }

  set {
    name  = "staging_tlsSecret"
    value = module.staging_app_wildcard.cert_secret_name
  }

  set {
    name  = "prod_host"
    value = "*.prod.apps.${var.cluster_domain}"
  }

  set {
    name  = "prod_tlsSecret"
    value = module.prod_app_wildcard.cert_secret_name
  }

  depends_on = [
    helm_release.istio
  ]
}

module "jaeger" {
  source = "../../tools/jaeger"

  elasticsearch_host     = var.jaeger_elasticsearch_host
  elasticsearch_username = var.jaeger_elasticsearch_username
  elasticsearch_password = var.jaeger_elasticsearch_password
  namespace              = module.istio_namespace.name
  cluster_domain         = var.cluster_domain
  toolchain_namespace    = var.toolchain_namespace
  ingress_class          = var.ingress_class
}
