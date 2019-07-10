# Create CRDs for the cert manager
resource "helm_release" "cert_manager_crds" {
  name      = "cert-manager-crds"
  namespace = module.system_namespace.name
  chart     = "${path.module}/helm/cert-manager-crds"
  timeout   = 600
  wait      = true

  depends_on = [kubernetes_cluster_role_binding.tiller_cluster_role_binding]
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

# Application gateway / ingress wiring components
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  namespace  = module.system_namespace.name
  chart      = "jetstack/cert-manager"
  repository = data.helm_repository.cert_manager.name
  timeout    = 90
  version    = "0.7.2"
  wait       = true

  set {
    name  = "ingressShim.defaultIssuerName"
    value = "lead-namespace-issuer"
  }
  set {
    name  = "ingressShim.defaultIssuerKind"
    value = "Issuer"
  }

  depends_on = [
    helm_release.cert_manager_crds,
    null_resource.cert_manager_crd_delay,
    kubernetes_cluster_role_binding.tiller_cluster_role_binding,
  ]
}

