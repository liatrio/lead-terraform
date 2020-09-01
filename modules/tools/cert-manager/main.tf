# Cert manager repo
data "helm_repository" "cert_manager" {
  name = "jetstack"
  url  = "https://charts.jetstack.io"
}

// remove this when new version of cert-manager is released (> 0.11.0)
// https://github.com/jetstack/cert-manager/commit/f2d465d75786f78a39f116652afb3da1290fe5d2#diff-e9ffc0a87cb6db9f112368571b4db41d
//resource "kubernetes_cluster_role" "cert_manager_leaderelection" {
//  metadata {
//    name = "cert-manager-leaderelection"
//  }
//  rule {
//    api_groups = ["cert-manager.io"]
//    resources  = ["certificates"]
//    verbs      = ["get"]
//  }
//}

# Application gateway / ingress wiring components
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  namespace  = var.namespace
  chart      = "jetstack/cert-manager"
  repository = data.helm_repository.cert_manager.name
  timeout    = 120
  version    = "v0.16.1"
  wait       = true

  set {
    name  = "global.leaderElection.namespace"
    value = var.namespace
  }
  set {
    name = "installCRDs"
    value = true
  }
  set {
    name  = "extraArgs[0]"
    value = "--issuer-ambient-credentials"
  }
  set {
    name  = "extraArgs[1]"
    value = "--dns01-recursive-nameservers=1.1.1.1:53\\,208.67.222.222:53"
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
}
