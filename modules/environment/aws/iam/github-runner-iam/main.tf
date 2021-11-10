resource "aws_iam_role" "github_runner_service_account" {
  name = "${var.name}-service-account"

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
        "StringEquals": {
          "${replace(var.aws_iam_openid_connect_provider_url, "https://", "")}:sub": "system:serviceaccount:${var.namespace}:${var.service_account_name}"
        }
      }
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "github_runner_role_assume_role_policy" {
  statement {
    sid     = "GithubRunnerAssumeRole"
    actions = ["sts:AssumeRole"]

    resources = var.roles
  }
}

resource "aws_iam_role_policy" "github_runners_pipeines" {
  name = "${var.name}-policy"
  role = aws_iam_role.github_runner_service_account.name

  policy = data.aws_iam_policy_document.github_runner_role_assume_role_policy.json
}
