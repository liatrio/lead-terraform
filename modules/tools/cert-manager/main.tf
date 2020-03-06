# Create CRDs for the cert manager
resource "helm_release" "cert_manager_crds" {
  name      = "cert-manager-crds"
  namespace = var.namespace
  chart     = "${path.module}/helm/cert-manager-crds"
  timeout   = 600
  wait      = true

  depends_on = [var.tiller_cluster_role_binding]
}

# Give the CRD a chance to settle
resource "null_resource" "cert_manager_crd_delay" {
  provisioner "local-exec" {
    command = "sleep 15"
  }
  depends_on = [helm_release.cert_manager_crds]
}

# Cert manager repo
data "helm_repository" "cert_manager" {
  name = "jetstack"
  url  = "https://charts.jetstack.io"
}

// remove this when new version of cert-manager is released (> 0.11.0)
// https://github.com/jetstack/cert-manager/commit/f2d465d75786f78a39f116652afb3da1290fe5d2#diff-e9ffc0a87cb6db9f112368571b4db41d
resource "kubernetes_cluster_role" "cert_manager_leaderelection" {
  metadata {
    name = "cert-manager-leaderelection"
  }
  rule {
    api_groups = ["cert-manager.io"]
    resources  = ["certificates"]
    verbs      = ["get"]
  }
}

# Application gateway / ingress wiring components
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  namespace  = var.namespace
  chart      = "jetstack/cert-manager"
  repository = data.helm_repository.cert_manager.name
  timeout    = 120
  version    = "v0.11.0"
  wait       = true

  set {
    name  = "global.leaderElection.namespace"
    value = var.namespace
  }
  set {
    name  = "extraArgs[0]"
    value = "--issuer-ambient-credentials"
  }
  set {
    name  = "serviceAccount.name"
    value = "cert-manager"
  }
  set {
    name  = "securityContext.enabled"
    value = true
  }
  set {
    name  = "securityContext.fsGroup"
    value = 1001
  }
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = var.cert_manager_service_account_role_arn
  }

  depends_on = [
    helm_release.cert_manager_crds,
    null_resource.cert_manager_crd_delay,
    var.tiller_cluster_role_binding,
    kubernetes_cluster_role.cert_manager_leaderelection,
  ]
}
