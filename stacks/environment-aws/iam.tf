module "cert_manager_iam" {
  source = "../../modules/environment/aws/iam/cert-manager"

  cluster                     = var.cluster
  namespace                   = var.system_namespace
  openid_connect_provider_arn = module.eks.aws_iam_openid_connect_provider.arn
  openid_connect_provider_url = module.eks.aws_iam_openid_connect_provider.url
}

module "external_dns_iam" {
  source = "../../modules/environment/aws/iam/external-dns"

  cluster                     = var.cluster
  namespace                   = var.system_namespace
  openid_connect_provider_arn = module.eks.aws_iam_openid_connect_provider.arn
  openid_connect_provider_url = module.eks.aws_iam_openid_connect_provider.url
  route53_zone_ids            = [
    aws_route53_zone.cluster_zone.zone_id
  ]
}

module "cluster_autoscaler_iam" {
  source = "../../modules/environment/aws/iam/cluster-autoscaler"

  cluster                     = var.cluster
  namespace                   = var.system_namespace
  openid_connect_provider_arn = module.eks.aws_iam_openid_connect_provider.arn
  openid_connect_provider_url = module.eks.aws_iam_openid_connect_provider.url
}

resource "aws_iam_role" "rode_service_account" {
  name = "${var.cluster}_rode_service_account"

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
          "${replace(module.eks.aws_iam_openid_connect_provider.url, "https://", "")}:sub": "system:serviceaccount:${var.toolchain_namespace}:rode"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "rode" {
  name = "${var.cluster}-rode"
  role = aws_iam_role.rode_service_account.name

  policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Effect": "Allow",
     "Action": [
       "sqs:CreateQueue"
       "sqs:SetQueueAttributes",
       "sqs:GetQueueUrl",
       "sqs:GetQueueAttributes",
       "sqs:ReceiveMessage",
       "sqs:DeleteMessage",
     ],
     "Resource": ["*"]
   },
   {
     "Effect": "Allow",
     "Action": [
       "events:PutTargets",
       "events:PutRule"
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
        "cloud9:DescribeEnvironmentMemberships",
        "cloud9:DescribeEnvironments",
        "cloud9:CreateEnvironmentMembership"
      ],
      "Resource": ["*"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:CreateRepository"
      ],
      "Resource": ["*"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codecommit:CreateRepository",
        "codecommit:GetRepository",
        "codecommit:TagResource",
        "codecommit:GitPull"
      ],
      "Resource": "*"
    }
  ]
}
EOF
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

resource "aws_iam_role" "product_operator_service_account" {
  name = "${var.cluster}-product-operator-service-account"

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
          "${replace(module.eks.aws_iam_openid_connect_provider.url, "https://", "")}:sub": "system:serviceaccount:${var.toolchain_namespace}:operator-product"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_policy" "product_operator_main" {
  name  = "${var.cluster}-product-operator-main"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
  {
    "Effect": "Allow",
    "Action": [
      "s3:ListBucket",
      "s3:GetBucketVersioning",
      "s3:CreateBucket",
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ],
    "Resource": [
      "arn:aws:s3:::lead-sdm-operators-${data.aws_caller_identity.current.account_id}-${var.cluster}.liatr.io"
    ]
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
    "Resource": [
      "arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/lead-sdm-operators-${var.cluster}"
    ]
  }]
}
EOF
}

resource "aws_iam_role_policy_attachment" "product_operator_main" {
  role       = aws_iam_role.product_operator_service_account.name
  policy_arn = aws_iam_policy.product_operator_main.arn
}

resource "aws_iam_policy" "product_operator_aws_code_services" {
  count = var.enable_aws_code_services ? 1 : 0
  name  = "${var.cluster}-product-operator-code-services"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
  {
    "Effect": "Allow",
    "Action": [
      "codebuild:StopBuild",
      "codepipeline:AcknowledgeThirdPartyJob",
      "codepipeline:DeletePipeline",
      "codebuild:UpdateProject",
      "codepipeline:PutThirdPartyJobFailureResult",
      "codepipeline:EnableStageTransition",
      "codepipeline:RetryStageExecution",
      "codepipeline:PutJobFailureResult",
      "codebuild:ImportSourceCredentials",
      "codepipeline:DisableStageTransition",
      "codepipeline:PutThirdPartyJobSuccessResult",
      "codepipeline:PollForThirdPartyJobs",
      "codepipeline:StartPipelineExecution",
      "codepipeline:PutJobSuccessResult",
      "codebuild:DeleteReportGroup",
      "codebuild:CreateProject",
      "codebuild:UpdateReportGroup",
      "codebuild:CreateReportGroup",
      "codepipeline:PutApprovalResult",
      "codepipeline:StopPipelineExecution",
      "codepipeline:AcknowledgeJob",
      "codebuild:DeleteReport",
      "codepipeline:UpdatePipeline",
      "codebuild:BatchDeleteBuilds",
      "codebuild:DeleteProject",
      "codebuild:StartBuild",
      "codebuild:BatchGetProjects",
      "codepipeline:CreatePipeline",
      "codepipeline:GetPipeline",
      "codepipeline:ListTagsForResource",
      "codepipeline:TagResource",
      "codepipeline:UntagResource"
    ],
    "Resource": "*"
  },
  {
    "Effect": "Allow",
    "Action": [
      "iam:PassRole"
    ],
    "Resource": [
      "${module.codeservices.codebuild_role}",
      "${module.codeservices.codepipeline_role}"
    ]
  },
  {
    "Effect": "Allow",
    "Action": [
      "ec2:DescribeVpc*",
      "ec2:DescribeSubnets"
    ],
    "Resource": "*"
  }]
}
EOF
}

resource "aws_iam_role_policy_attachment" "product_operator_aws_code_services" {
  count      = var.enable_aws_code_services ? 1 : 0
  role       = aws_iam_role.product_operator_service_account.name
  policy_arn = aws_iam_policy.product_operator_aws_code_services[0].arn
}
