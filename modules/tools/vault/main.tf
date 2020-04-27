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

module "vault_tls_certificate" {
  source = "../../common/certificates"

  name      = "vault-tls"
  namespace = var.namespace
  domain    = var.vault_hostname
  enabled   = true

  issuer_name = var.cert_issuer_name
  issuer_kind = var.cert_issuer_kind

  certificate_crd = var.cert_crd_waiter
}

resource "helm_release" "vault" {
  chart     = "${path.module}/charts/vault-helm"
  name      = "vault"
  namespace = var.namespace
  wait      = true

  values = [
    templatefile("${path.module}/values.tpl", {
      vault_tls_secret = module.vault_tls_certificate.cert_secret_name
      vault_hostname   = var.vault_hostname
      vault_config     = indent(6, templatefile("${path.module}/vault-config.hcl.tpl", {
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
