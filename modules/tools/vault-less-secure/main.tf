resource "aws_dynamodb_table" "vault_dynamodb_storage" {
  name           = var.vault_dynamodb_table_name
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "Path"
  range_key      = "Key"

  attribute {
    name = "Path"
    type = "S"
  }

  attribute {
    name = "Key"
    type = "S"
  }
}

resource "aws_kms_key" "vault_seal_key" {
  description = "KMS key used by Vault for sealing / unsealing"
}

resource "aws_iam_user" "vault" {
  name = "vault"
}

resource "aws_iam_user_policy" "vault" {
  user   = aws_iam_user.vault.name
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:DescribeLimits",
        "dynamodb:DescribeTimeToLive",
        "dynamodb:ListTagsOfResource",
        "dynamodb:DescribeReservedCapacityOfferings",
        "dynamodb:DescribeReservedCapacity",
        "dynamodb:ListTables",
        "dynamodb:BatchGetItem",
        "dynamodb:BatchWriteItem",
        "dynamodb:CreateTable",
        "dynamodb:DeleteItem",
        "dynamodb:GetItem",
        "dynamodb:GetRecords",
        "dynamodb:PutItem",
        "dynamodb:Query",
        "dynamodb:UpdateItem",
        "dynamodb:Scan",
        "dynamodb:DescribeTable"
      ],
      "Effect": "Allow",
      "Resource": "${aws_dynamodb_table.vault_dynamodb_storage.arn}"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "iam:GetInstanceProfile",
        "iam:GetUser",
        "iam:GetRole"
      ],
      "Resource": "*"
    },
    {
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:DescribeKey"
      ],
      "Effect": "Allow",
      "Resource": "${aws_kms_key.vault_seal_key.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_access_key" "vault" {
  user = aws_iam_user.vault.name
}

resource "helm_release" "vault" {
  chart      = "vault"
  name       = "vault"
  namespace  = var.namespace
  repository = "https://helm.releases.hashicorp.com"
  version    = "0.6.0"
  wait       = true

  values = [
    templatefile("${path.module}/vault-values.tpl", {
      vault_hostname = var.vault_hostname
      vault_version  = "1.4.2"
      vault_config = indent(6, templatefile("${path.module}/vault-config.hcl.tpl", {
        region                = var.region
        aws_access_key_id     = aws_iam_access_key.vault.id
        aws_secret_access_key = aws_iam_access_key.vault.secret
        dynamodb_table_name   = aws_dynamodb_table.vault_dynamodb_storage.name
        kms_key_id            = aws_kms_key.vault_seal_key.key_id
      }))
    })
  ]

  depends_on = [
    aws_iam_user.vault,
    aws_iam_user_policy.vault,
    aws_iam_access_key.vault,
    aws_kms_key.vault_seal_key,
    aws_dynamodb_table.vault_dynamodb_storage
  ]
}

resource "helm_release" "vault-injector" {
  chart      = "vault"
  name       = "vault-injector"
  namespace  = var.namespace
  repository = "https://helm.releases.hashicorp.com"
  version    = "0.6.0"
  wait       = true

  values = [
    templatefile("${path.module}/vault-injector-values.tpl", {
      vault_hostname = "https://${var.vault_hostname}"
    })
  ]

  depends_on = [
    helm_release.vault
  ]
}

module "vault_operator_init" {
  source = "matti/resource/shell"

  command = "kubectl exec -it -n ${var.namespace} vault-0 -- vault operator init -format=json | jq -rc '.root_token'"
  depends = [
    helm_release.vault.id
  ]
}

resource "kubernetes_secret" "vault_root_token" {
  metadata {
    namespace = var.namespace
    name      = "vault-root-token"
  }

  data = {
    token = module.vault_operator_init.stdout
  }
}

resource "kubernetes_service_account" "vault_token_reviewer" {
  metadata {
    name      = "vault-token-reviewer"
    namespace = var.namespace
  }
}

resource "kubernetes_cluster_role_binding" "vault_token_reviewer" {
  metadata {
    name = "vault-tokenreview-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.vault_token_reviewer.metadata[0].name
    namespace = kubernetes_service_account.vault_token_reviewer.metadata[0].namespace
  }
}

data "kubernetes_secret" "vault_token_reviewer_service_account_token" {
  metadata {
    name      = kubernetes_service_account.vault_token_reviewer.default_secret_name
    namespace = kubernetes_service_account.vault_token_reviewer.metadata[0].namespace
  }
}

resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "k8s_vault_backend_config" {
  backend            = vault_auth_backend.kubernetes.path
  kubernetes_host    = "https://kubernetes.default.svc"
  kubernetes_ca_cert = data.kubernetes_secret.vault_token_reviewer_service_account_token.data["ca.crt"]
  token_reviewer_jwt = data.kubernetes_secret.vault_token_reviewer_service_account_token.data["token"]
}

resource "vault_mount" "mongodb" {
  path = "mongodb"
  type = "database"
}