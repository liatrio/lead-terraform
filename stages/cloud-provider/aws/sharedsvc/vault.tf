#tfsec:ignore:aws-dynamodb-enable-recovery
#tfsec:ignore:aws-dynamodb-table-customer-key
resource "aws_dynamodb_table" "vault_dynamodb_storage" {
  name           = var.vault_dynamodb_table_name
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

# We ignore the recommendation to auto-rotate keys out of an abundance of caution,
# as it is possible that rotating the unseal key could break Vault. Having said that, it
# appears that it should be possible to use automatic AWS KMS key rotation, as we
# use the awskms seal[1]. It is currently not possible to test the automatic key
# rotation mechanism, as keys rotate annually, and manually roating keys functions
# differently than automatically rotating keys[2]. Consequently, for the time being,
# we have enabled automatic key rotaion in lead by not shared services.

# 1. https://www.vaultproject.io/docs/configuration/seal/awskms#key-rotation
# 2. https://docs.aws.amazon.com/kms/latest/developerguide/rotate-keys.html

#tfsec:ignore:aws-kms-auto-rotate-keys
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
