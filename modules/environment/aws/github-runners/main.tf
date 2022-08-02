data "aws_caller_identity" "current" {
}

#tfsec:ignore:aws-s3-enable-versioning
resource "aws_s3_bucket" "github-runner" {
  bucket = "github-runners-${data.aws_caller_identity.current.account_id}-${var.cluster_name}.liatr.io"
  tags = {
    Name      = "Github Runner States"
    ManagedBy = "Terraform https://github.com/liatrio/lead-terraform"
    Cluster   = var.cluster_name
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.github_runner_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "aws_kms_key" "github_runner_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_s3_bucket_logging" "github_runner_logging" {
  bucket = aws_s3_bucket.github-runner.id

  target_bucket = "s3-logging-${var.account_id}-${var.cluster_name}"
  target_prefix = "GitHubRunnerLogs/"
}

# Used to restrict public access and block users from creating policies to enable it
resource "aws_s3_bucket_public_access_block" "github-runner_block" {
  bucket                  = aws_s3_bucket.github-runner.id
  block_public_acls       = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  block_public_policy     = true
}


resource "aws_iam_role" "github_runners_service_account" {
  name = "${var.cluster_name}_github_runners_service_account"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${var.aws_iam_openid_connect_provider_arn}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "ForAnyValue:StringEquals": {
          "${replace(var.aws_iam_openid_connect_provider_url, "https://", "")}:sub": ${jsonencode(formatlist("system:serviceaccount:%s", var.service_accounts))}
        }
      }
    }
  ]
}
EOF

  permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/Developer"
}

resource "aws_iam_policy" "github_runners" {
  name = "${var.cluster_name}-github-runners"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetBucketVersioning",
        "s3:CreateBucket"
      ],
      "Resource": ["${aws_s3_bucket.github-runner.arn}"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": ["${aws_s3_bucket.github-runner.arn}/*"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:PutItem",
        "dynamodb:GetItem",
        "dynamodb:DescribeTable",
        "dynamodb:DeleteItem",
        "dynamodb:CreateTable",
        "dynamodb:TagResource"
      ],
      "Resource": ["arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/github-runners-${var.cluster_name}"]
    },
    {
      "Sid": "AssumeGithubRunnerApplicationRole",
      "Effect": "Allow",
      "Action": [
        "sts:AssumeRole"
      ],
      "Resource": [
        "arn:aws:iam::489130170427:role/GithubRunnerApplication",
        "arn:aws:iam::281127131043:role/GithubRunnerApplication"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "github_runners" {
  role       = aws_iam_role.github_runners_service_account.name
  policy_arn = aws_iam_policy.github_runners.arn
}
