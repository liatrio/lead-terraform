resource "aws_iam_role" "external_dns_service_account" {
  name = "${var.cluster}_external_dns_service_account"

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
          "${replace(var.openid_connect_provider_url, "https://", "")}:sub": "system:serviceaccount:${var.namespace}:external-dns"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "external_dns" {
  name = "${var.cluster}-external-dns"
  role = aws_iam_role.external_dns_service_account.name

  policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Effect": "Allow",
     "Action": [
       "route53:ChangeResourceRecordSets",
       "route53:ListResourceRecordSets"
     ],
     "Resource": ${jsonencode(formatlist("arn:aws:route53:::hostedzone/%s", var.route53_zone_ids))}
   },
   {
     "Effect": "Allow",
     "Action": [
       "route53:ListHostedZones",
       "route53:GetChange"
     ],
     "Resource": ["*"]
   }
 ]
}
EOF
}
