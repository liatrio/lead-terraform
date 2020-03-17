data "aws_caller_identity" "current" {
}

resource "aws_iam_role" "cert_manager_service_account" {
  name = "${var.cluster}_cert_manager_service_account"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${module.eks.aws_iam_openid_connect_provider.arn}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${replace(module.eks.aws_iam_openid_connect_provider.url, "https://", "")}:sub": "system:serviceaccount:${var.system_namespace}:cert-manager"
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
        "Action": "route53:ChangeResourceRecordSets",
        "Resource": "arn:aws:route53:::hostedzone/*"
    },
    {
        "Effect": "Allow",
        "Action": "route53:ListHostedZonesByName",
        "Resource": "*"
    }
 ]
}
EOF
}

resource "aws_iam_role" "external_dns_service_account" {
  name = "${var.cluster}_external_dns_service_account"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${module.eks.aws_iam_openid_connect_provider.arn}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${replace(module.eks.aws_iam_openid_connect_provider.url, "https://", "")}:sub": "system:serviceaccount:${var.system_namespace}:external-dns"
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
     "Resource": [
       "arn:aws:route53:::hostedzone/${aws_route53_zone.cluster_zone.zone_id}"
     ]
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

resource "aws_iam_role" "operator_slack_service_account" {
  name = "${var.cluster}_operator_slack_service_account"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${module.eks.aws_iam_openid_connect_provider.arn}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${replace(module.eks.aws_iam_openid_connect_provider.url, "https://", "")}:sub": "system:serviceaccount:${var.toolchain_namespace}:operator-slack"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "operator-slack" {
  name = "${var.cluster}-operator-slack"
  role = aws_iam_role.operator_slack_service_account.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sts:AssumeRole"
      ],
      "Resource": [
        "${module.eks.workspace_iam_role.arn}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloud9:DescribeEnvironmentMemberships", "cloud9:DescribeEnvironments"
      ],
      "Resource": ["*"]
    },
    {
      "Effect": "Allow",
      "Action": "codecommit:CreateRepository",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "cluster_autoscaler_service_account" {
  name = "${var.cluster}_cluster_autoscaler_service_account"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${module.eks.aws_iam_openid_connect_provider.arn}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${replace(module.eks.aws_iam_openid_connect_provider.url, "https://", "")}:sub": "system:serviceaccount:${var.system_namespace}:cluster-autoscaler-aws-cluster-autoscaler"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  role       = aws_iam_role.cluster_autoscaler_service_account.name
  policy_arn = aws_iam_policy.cluster_autoscaler.arn
}

resource "aws_iam_policy" "cluster_autoscaler" {
  name_prefix = "cluster-autoscaler"
  description = "EKS cluster-autoscaler policy for cluster ${module.eks.cluster_id}"
  policy      = data.aws_iam_policy_document.cluster_autoscaler.json
}

data "aws_iam_policy_document" "cluster_autoscaler" {
  statement {
    sid    = "clusterAutoscalerAll"
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeLaunchTemplateVersions",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "clusterAutoscalerOwn"
    effect = "Allow"

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/kubernetes.io/cluster/${module.eks.cluster_id}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/kubernetes.io/cluster-autoscaler/enabled"
      values   = ["true"]
    }
  }
}

resource "aws_iam_role" "operator_jenkins_service_account" {
  name = "${var.cluster}_operator_jenkins_service_account"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${module.eks.aws_iam_openid_connect_provider.arn}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${replace(module.eks.aws_iam_openid_connect_provider.url, "https://", "")}:sub": "system:serviceaccount:${module.toolchain.namespace}:operator-jenkins"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_policy" "operator_jenkins" {
  name = "${var.cluster}-operator-jenkins"

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
     "Resource": ["arn:aws:s3:::lead-sdm-operators-${data.aws_caller_identity.current.account_id}-${var.cluster}.liatr.io"]
   },
   {
     "Effect": "Allow",
     "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject"
     ],
     "Resource": ["arn:aws:s3:::lead-sdm-operators-${data.aws_caller_identity.current.account_id}-${var.cluster}.liatr.io/*"]
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
     "Resource": ["arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/lead-sdm-operators-${var.cluster}"]
   }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "operator_jenkins" {
  role       = aws_iam_role.operator_jenkins_service_account.name
  policy_arn = aws_iam_policy.operator_jenkins.arn
}
