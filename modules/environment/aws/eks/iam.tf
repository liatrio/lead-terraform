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
  count = var.enable_aws_code_services ? 0 : 1
  name  = "workspace_access"
  role  = aws_iam_role.workspace_role.name

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
        "codecommit:GitPush", "codecommit:GitPull"
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

resource "aws_iam_role_policy" "workspace_role_policy_codeservices" {
  count = var.enable_aws_code_services ? 1 : 0
  name  = "workspace_access"
  role  = aws_iam_role.workspace_role.name

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
        "codecommit:GitPush", "codecommit:GitPull"
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
    },
    {
      "Action": [
        "codepipeline:ListPipelines",
        "codepipeline:ListPipelineExecutions",
        "codepipeline:GetPipeline",
        "codepipeline:GetPipelineExecution",
        "codepipeline:GetPipelineState"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "codebuild:BatchGetBuilds"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "logs:GetLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "ecr:DescribeRepositories",
        "ecr:DescribeImages"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
