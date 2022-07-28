data "aws_caller_identity" "current" {}

resource "aws_iam_role" "cert_manager_service_account" {
  name = "${var.cluster}_cert_manager_service_account"

  permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/Developer"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${var.openid_connect_provider_arn}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${replace(var.openid_connect_provider_url, "https://", "")}:sub": "system:serviceaccount:${var.namespace}:cert-manager"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cert_manager" {
  name = "${var.cluster}-cert-manager"
  role = aws_iam_role.cert_manager_service_account.name

  policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
    {
        "Effect": "Allow",
        "Action": "route53:GetChange",
        "Resource": "arn:aws:route53:::change/*"
    },
    {
        "Effect": "Allow",
        "Action":  [
          "route53:ChangeResourceRecordSets",
          "route53:ListResourceRecordSets"
        ],
        "Resource": "arn:aws:route53:::hostedzone/*"
    }
 ]
}
EOF
}
