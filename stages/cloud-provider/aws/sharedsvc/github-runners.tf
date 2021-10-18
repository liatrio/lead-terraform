module "github-runners-s3" {
  source = "../../../../modules/environment/aws/github-runners-s3"

  name                                = var.cluster_name
  service_accounts                    = var.github_runner_service_accounts
  aws_iam_openid_connect_provider_arn = module.eks.aws_iam_openid_connect_provider_arn
  aws_iam_openid_connect_provider_url = module.eks.aws_iam_openid_connect_provider_url
}

resource "aws_iam_role" "lead_pipelines_service_account" {
  name = "${module.eks.cluster_id}-lead-pipelines-service-account"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${module.eks.aws_iam_openid_connect_provider_arn}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${replace(module.eks.aws_iam_openid_connect_provider_url, "https://", "")}:sub": "system:serviceaccount:${var.github_runners_namespace}:liatrio-lead-environments-runners"
        }
      }
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "lead_pipelines_role_assume_role_policy" {
  statement {
    sid     = "LeadPipelinesAssumeRole"
    actions = ["sts:AssumeRole"]

    resources = var.lead_environments_pipeline_roles
  }
}

resource "aws_iam_role_policy" "lead_pipeines" {
  name = "${module.eks.cluster_id}-lead-pipelines"
  role = aws_iam_role.lead_pipelines_service_account.name

  policy = data.aws_iam_policy_document.lead_pipelines_role_assume_role_policy.json
}
