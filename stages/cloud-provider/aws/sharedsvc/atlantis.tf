resource "aws_iam_role" "atlantis_service_account" {
  name = "${module.eks.cluster_id}-atlantis-service-account"

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
          "${replace(module.eks.aws_iam_openid_connect_provider_url, "https://", "")}:sub": "system:serviceaccount:${var.atlantis_namespace}:atlantis"
        }
      }
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "atlantis_role_assume_role_policy" {
  statement {
    sid     = "AtlantisAssumeRole"
    actions = ["sts:AssumeRole"]

    resources = var.lead_environments_pipeline_roles
  }
}

resource "aws_iam_role_policy" "atlantis" {
  name = "${module.eks.cluster_id}-atlantis"
  role = aws_iam_role.atlantis_service_account.name

  policy = data.aws_iam_policy_document.atlantis_role_assume_role_policy.json
}
