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

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        # Cert-Manager can be limited in the access it has for each hosted zone that it touches,
        #   but according to the docs[1], "cert-manager needs to be able to add records to 
        #   Route53 in order to solve the DNS01 challenge."
        #
        # 1. https://cert-manager.io/docs/configuration/acme/dns01/route53/#set-up-an-iam-role

        #tfsec:ignore:aws-iam-no-policy-wildcards
        {
          "Effect" : "Allow",
          "Action" : "route53:GetChange",
          "Resource" : "arn:aws:route53:::change/*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "route53:ChangeResourceRecordSets",
            "route53:ListResourceRecordSets"
          ],
          "Resource" : "${formatlist("arn:aws:route53:::hostedzone/%s", var.hosted_zone_ids)}"
        }
      ]
  })
}
