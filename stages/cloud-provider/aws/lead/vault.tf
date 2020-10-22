resource "aws_dynamodb_table" "vault_dynamodb_storage" {
  name           = "vault.${var.toolchain_namespace}.${var.cluster_name}.${var.root_zone_name}"
  read_capacity  = 25
  write_capacity = 25
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

resource "aws_iam_user" "vault_user" {
  name = "${var.cluster_name}-vault"
}

resource "aws_iam_user_policy" "vault" {
  user   = aws_iam_user.vault_user.name
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

resource "aws_iam_access_key" "vault_key" {
  user = aws_iam_user.vault_user.name
}
