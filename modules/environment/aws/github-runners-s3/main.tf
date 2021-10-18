data "aws_caller_identity" "current" {
}

#tfsec:ignore:aws-s3-enable-versioning
#tfsec:ignore:aws-s3-enable-bucket-logging
#tfsec:ignore:aws-s3-specify-public-access-block
#tfsec:ignore:aws-s3-enable-bucket-encryption
resource "aws_s3_bucket" "github-runner" {
  bucket = "github-runners-${data.aws_caller_identity.current.account_id}-${var.name}.liatr.io"
  tags = {
    Name      = "Github Runner States"
    ManagedBy = "Terraform https://github.com/liatrio/lead-terraform"
    Cluster   = var.name
  }
}


resource "aws_iam_role" "github_runners_service_account" {
  count = var.iam_role_name == "" ? 1 : 0
  name  = "${var.name}_github_runners_service_account"

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
}

resource "aws_iam_policy" "github_runners" {
  name = "${var.name}-github-runners"

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
     "Resource": ["arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/github-runners-${var.name}"]
   }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "github_runners" {
  role       = var.iam_role_name == "" ? aws_iam_role.github_runners_service_account[0].name : var.iam_role_name
  policy_arn = aws_iam_policy.github_runners.arn
}

// this is needed in order to provide the role arn as an output when this module does not create the IAM role
data "aws_iam_role" "iam_role" {
  count = var.iam_role_name == "" ? 0 : 1
  name  = var.iam_role_name
}
