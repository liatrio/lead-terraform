# Cert manager repo
data "helm_repository" "cert_manager" {
  name = "jetstack"
  url  = "https://charts.jetstack.io"
}

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
