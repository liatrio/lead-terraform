resource "aws_iam_openid_connect_provider" "default" {
  url = module.eks.cluster_oidc_issuer_url

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = ["9E99A48A9960B14926BB7F3B02E22DA2B0AB7280"]
}

resource "aws_iam_role" "terraform_pod_template_role" {
  name = "${var.cluster}_terraform_pod_template_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${aws_iam_openid_connect_provider.default.arn}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringLike": {
          "${replace(aws_iam_openid_connect_provider.default.url, "https://", "")}:sub": "system:serviceaccount:*-toolchain:terraform-iam"
        }
      }
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
        "Federated": "${aws_iam_openid_connect_provider.default.arn}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${replace(aws_iam_openid_connect_provider.default.url, "https://", "")}:sub": "system:serviceaccount:${var.system_namespace}:external-dns"
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

resource "aws_iam_policy" "worker_policy" {
  name = "${var.cluster}-worker-policy"

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
       "${aws_iam_role.workspace_role.arn}"
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
                "s3:GetObject"
     ],
     "Resource": ["arn:aws:s3:::lead-sdm-operators-${data.aws_caller_identity.current.account_id}-${var.cluster}.liatr.io"]
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

resource "aws_iam_role_policy_attachment" "worker_ecr_role_attachment" {
  role = module.eks.worker_iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}
resource "aws_iam_role_policy_attachment" "worker_ssm_role_attachment" {
  role = module.eks.worker_iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role" "workspace_role" {
  name = "${var.cluster}_workspace_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF


  permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${aws_iam_policy.workspace_role_boundary.name}"
}

resource "aws_iam_policy" "workspace_role_boundary" {
  name        = "${var.cluster}-workspace_role_boundary"
  description = "Permission boundaries for workspace role"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "NotAction": [
                "iam:*",
                "organizations:*",
                "account:*"
            ],
            "Resource": "*"
        },
        {
            "Action": [
                "iam:Get*",
                "iam:List*",
                "iam:CreateInstanceProfile",
                "iam:DeleteInstanceProfile",
                "iam:AddRoleToInstanceProfile",
                "iam:RemoveRoleFromInstanceProfile",
                "iam:CreatePolicy",
                "iam:CreateServiceLinkedRole",
                "iam:DeleteServiceLinkedRole",
                "organizations:DescribeOrganization",
                "account:ListRegions"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": [
                "iam:CreateRole",
                "iam:AttachRolePolicy",
                "iam:PutRolePermissionsBoundary"
            ],
            "Effect": "Allow",
            "Condition": {
                "StringEquals": {
                    "iam:PermissionsBoundary": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.cluster}-workspace_role_boundary}"
                }
            },
            "Resource": "*"
        },
        {
            "Action": [
                "iam:PassRole"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "workspace_role_attachment" {
  role       = aws_iam_role.workspace_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCloud9User"
}

resource "aws_iam_role_policy" "workspace_role_policy" {
  name = "workspace_access"
  role = aws_iam_role.workspace_role.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "eks:DescribeCluster"
      ],
      "Effect": "Allow",
      "Resource": "${module.eks.cluster_arn}"
    },
    {
      "Action": [
        "ec2:DescribeInstances","ec2:DescribeVolumesModifications"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "ec2:ModifyVolume"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
