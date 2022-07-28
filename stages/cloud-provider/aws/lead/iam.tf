module "cert_manager_iam" {
  source = "../../../../modules/environment/aws/iam/cert-manager"

  cluster                     = var.cluster_name
  namespace                   = var.system_namespace
  hosted_zone_ids             = [aws_route53_zone.cluster_zone.zone_id]
  openid_connect_provider_arn = module.eks.aws_iam_openid_connect_provider_arn
  openid_connect_provider_url = module.eks.aws_iam_openid_connect_provider_url
}

module "external_dns_iam" {
  source = "../../../../modules/environment/aws/iam/external-dns"

  cluster                     = var.cluster_name
  namespace                   = var.system_namespace
  openid_connect_provider_arn = module.eks.aws_iam_openid_connect_provider_arn
  openid_connect_provider_url = module.eks.aws_iam_openid_connect_provider_url
  route53_zone_ids = compact([
    aws_route53_zone.cluster_zone.zone_id,
    var.enable_vcluster ? aws_route53_zone.vcluster[0].zone_id : ""
  ])
}

module "cluster_autoscaler_iam" {
  source = "../../../../modules/environment/aws/iam/cluster-autoscaler"

  cluster                     = var.cluster_name
  namespace                   = var.system_namespace
  openid_connect_provider_arn = module.eks.aws_iam_openid_connect_provider_arn
  openid_connect_provider_url = module.eks.aws_iam_openid_connect_provider_url
}

module "velero_iam" {
  count  = var.enable_velero ? 1 : 0
  source = "../../../../modules/environment/aws/iam/velero"

  cluster                     = var.cluster_name
  namespace                   = var.velero_namespace
  velero_bucket_name          = module.velero[0].velero_bucket_name
  openid_connect_provider_arn = module.eks.aws_iam_openid_connect_provider_arn
  openid_connect_provider_url = module.eks.aws_iam_openid_connect_provider_url
}

# TODO: remove trust policy for operator-slack once it is fully deprecated
resource "aws_iam_role" "sparky_service_account" {
  name = "${var.cluster_name}-sparky-service-account"

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
          "${replace(module.eks.aws_iam_openid_connect_provider_url, "https://", "")}:sub": [
            "system:serviceaccount:${var.toolchain_namespace}:operator-slack",
            "system:serviceaccount:${var.toolchain_namespace}:sparky"
          ]
        }
      }
    }
  ]
}
EOF

  permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/Developer"

}

resource "aws_iam_role_policy" "sparky" {
  name = "${var.cluster_name}-sparky"
  role = aws_iam_role.sparky_service_account.name

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

resource "aws_iam_role" "product_operator_service_account" {
  name = "${var.cluster_name}-product-operator-service-account"

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
          "${replace(module.eks.aws_iam_openid_connect_provider_url, "https://", "")}:sub": "system:serviceaccount:${var.toolchain_namespace}:product-operator"
        }
      }
    }
  ]
}
EOF

  permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/Developer"
}

resource "aws_iam_policy" "product_operator_main" {
  name = "${var.cluster_name}-product-operator-main"

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
      "arn:aws:s3:::lead-sdm-operators-${data.aws_caller_identity.current.account_id}-${var.cluster_name}.liatr.io",
      "arn:aws:s3:::lead-sdm-operators-${data.aws_caller_identity.current.account_id}-${var.cluster_name}.liatr.io/*"
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
      "arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/lead-sdm-operators-${var.cluster_name}"
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
  name  = "${var.cluster_name}-product-operator-code-services"

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
      "${module.codeservices[0].codebuild_role}",
      "${module.codeservices[0].codepipeline_role}"
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
