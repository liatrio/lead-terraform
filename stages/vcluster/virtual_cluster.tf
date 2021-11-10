locals {
  vcluster_kubeconfig                           = yamldecode(data.kubernetes_secret.vcluster_kubeconfig.data["config"])
  aws_pod_identity_webhook_service_account_name = "aws-pod-identity-webhook"
  aws_pod_identity_webhook_namespace            = "kube-system"
}

provider "kubernetes" {
  alias = "vcluster"

  // cluster
  host                   = local.vcluster_kubeconfig.clusters[0].cluster.server
  cluster_ca_certificate = base64decode(local.vcluster_kubeconfig.clusters[0].cluster.certificate-authority-data)

  // user
  username           = local.vcluster_kubeconfig.users[0].name
  client_certificate = base64decode(local.vcluster_kubeconfig.users[0].user.client-certificate-data)
  client_key         = base64decode(local.vcluster_kubeconfig.users[0].user.client-key-data)
}

provider "helm" {
  alias = "vcluster"

  kubernetes {
    // cluster
    host                   = local.vcluster_kubeconfig.clusters[0].cluster.server
    cluster_ca_certificate = base64decode(local.vcluster_kubeconfig.clusters[0].cluster.certificate-authority-data)

    // user
    username           = local.vcluster_kubeconfig.users[0].name
    client_certificate = base64decode(local.vcluster_kubeconfig.users[0].user.client-certificate-data)
    client_key         = base64decode(local.vcluster_kubeconfig.users[0].user.client-key-data)
  }
}

// rbac is needed for unauthenticated access to the JWKS endpoint
resource "kubernetes_cluster_role_binding" "oidc_viewer" {
  provider = kubernetes.vcluster

  metadata {
    name = "oidc-viewer"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:service-account-issuer-discovery"
  }

  subject {
    kind = "Group"
    name = "system:unauthenticated"
  }

  depends_on = [
    module.wait_for_vcluster,
    data.kubernetes_secret.vcluster_kubeconfig
  ]
}

resource "helm_release" "aws_pod_identity_webhook" {
  provider = helm.vcluster

  chart     = "${path.module}/aws-pod-identity-webhook"
  name      = "aws-pod-identity-webhook"
  namespace = local.aws_pod_identity_webhook_namespace
  timeout   = 300
  wait      = true

  set {
    name  = "tokenAudience"
    value = var.vcluster_apiserver_host
  }

  set {
    name  = "caBundle"
    value = base64encode(tls_self_signed_cert.ca_cert.cert_pem)
  }

  set {
    name  = "serviceAccount.name"
    value = local.aws_pod_identity_webhook_service_account_name
  }

  depends_on = [
    module.wait_for_vcluster,
    data.kubernetes_secret.vcluster_kubeconfig
  ]
}

// the "aws-pod-identity-webhook" workload creates a CSR and sends it to the kube-controller-manager.
// we can normally approve this via "kubectl certificate approve ${CSR_NAME}"
// but to do it automatically, we'll create a job that runs this for us after the helm release is ready

resource "kubernetes_service_account" "csr_approver" {
  provider = kubernetes.vcluster

  metadata {
    name      = "csr-approver"
    namespace = local.aws_pod_identity_webhook_namespace
  }

  depends_on = [
    helm_release.aws_pod_identity_webhook
  ]
}

resource "kubernetes_cluster_role" "csr_approver" {
  provider = kubernetes.vcluster

  metadata {
    name = "csr-approver"
  }

  rule {
    api_groups = [
      "certificates.k8s.io"
    ]
    resources = [
      "certificatesigningrequests"
    ]
    verbs = [
      "get",
      "list"
    ]
  }

  rule {
    api_groups = [
      "certificates.k8s.io"
    ]
    resources = [
      "certificatesigningrequests/approval"
    ]
    verbs = [
      "update"
    ]
  }

  rule {
    api_groups = [
      "certificates.k8s.io"
    ]
    resources = [
      "signers"
    ]
    resource_names = [
      "kubernetes.io/legacy-unknown"
    ]
    verbs = [
      "approve"
    ]
  }

  depends_on = [
    helm_release.aws_pod_identity_webhook
  ]
}

resource "kubernetes_cluster_role_binding" "csr_approver" {
  provider = kubernetes.vcluster

  metadata {
    name = "csr-approver"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.csr_approver.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.csr_approver.metadata[0].name
    namespace = kubernetes_service_account.csr_approver.metadata[0].namespace
  }
}

resource "kubernetes_config_map" "csr_approval_script" {
  provider = kubernetes.vcluster

  metadata {
    name      = "csr-approval-script"
    namespace = kubernetes_service_account.csr_approver.metadata[0].namespace
  }

  data = {
    "approve-csr.sh" = file("${path.module}/approve-csr.sh")
  }

  depends_on = [
    helm_release.aws_pod_identity_webhook
  ]
}

resource "kubernetes_job" "approve_csr" {
  provider = kubernetes.vcluster

  metadata {
    name      = "approve-csr"
    namespace = kubernetes_service_account.csr_approver.metadata[0].namespace
  }
  spec {
    template {
      metadata {
        name = "approve-csr"
      }

      spec {
        service_account_name = kubernetes_service_account.csr_approver.metadata[0].name
        volume {
          name = "script"
          config_map {
            name         = kubernetes_config_map.csr_approval_script.metadata[0].name
            default_mode = "0755"
          }
        }
        container {
          name  = "approve-csr"
          image = "bitnami/kubectl:1.21"

          env {
            name = "NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }

          env {
            name  = "SERVICE_ACCOUNT_NAME"
            value = local.aws_pod_identity_webhook_service_account_name
          }

          volume_mount {
            mount_path = "/script"
            name       = "script"
          }

          command = [
            "bash",
            "/script/approve-csr.sh"
          ]
        }
      }
    }
  }

  depends_on = [
    helm_release.aws_pod_identity_webhook
  ]
}
