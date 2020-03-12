resource "aws_s3_bucket" "codestar_bucket" {
  count  = var.enable-aws-codestar ? 1 : 0
  bucket = "codestar-${data.aws_caller_identity.current.account_id}-${var.cluster}"
  region = var.region
  versioning {
    enabled = true
  }

}

resource "aws_iam_role" "codebuild_role" {
  count  = var.enable-aws-codestar ? 1 : 0
  name = "codebuild-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codebuild_policy" {
  count  = var.enable-aws-codestar ? 1 : 0
  role = aws_iam_role.codebuild_role.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeDhcpOptions",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcs"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Resource": [
          "*"
      ],
      "Action": [
          "codecommit:GitPull"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "${aws_s3_bucket.codestar_bucket.arn}",
        "${aws_s3_bucket.codestar_bucket.arn}/*"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_role" "codepipeline_role" {
  count  = var.enable-aws-codestar ? 1 : 0
  name = "codepipeline-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  count  = var.enable-aws-codestar ? 1 : 0
  name = "codepipeline_policy"
  role = aws_iam_role.codepipeline_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObject"
      ],
      "Resource": [
        "${aws_s3_bucket.codestar_bucket.arn}",
        "${aws_s3_bucket.codestar_bucket.arn}/*"
      ]
    },
		{
			"Action": [
					"codecommit:CancelUploadArchive",
					"codecommit:GetBranch",
					"codecommit:GetCommit",
					"codecommit:GetUploadArchiveStatus",
					"codecommit:UploadArchive"
			],
			"Resource": "*",
			"Effect": "Allow"
		},
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_sqs_queue" "codestar_queue" {
  count  = var.enable-aws-codestar ? 1 : 0
  name                      = "codestar-${data.aws_caller_identity.current.account_id}-${var.cluster}"
  message_retention_seconds = 86400
}

resource "aws_cloudwatch_event_rule" "codestar_event_rule" {
  count  = var.enable-aws-codestar ? 1 : 0
  name        = "codestar-event-rule"
  description = "codestar-event-rule"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.codepipeline"
  ]
}
PATTERN
}

resource "aws_cloudwatch_event_target" "codestar_event_target" {
  count  = var.enable-aws-codestar ? 1 : 0
  rule      = "${aws_cloudwatch_event_rule.codestar_event_rule.name}"
  arn       = "${aws_sqs_queue.codestar_queue.arn}"
}

resource "aws_sqs_queue_policy" "codestar_queue_policy" {
  count  = var.enable-aws-codestar ? 1 : 0
  queue_url = "${aws_sqs_queue.codestar_queue.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "codestar-sqs-policy",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.codestar_queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_cloudwatch_event_rule.codestar_event_rule.arn}"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_iam_role" "product_operator_service_account" {
  count  = var.enable-aws-codestar ? 1 : 0
  name = "${var.cluster}_product_operator_service_account"

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
          "${replace(module.eks.aws_iam_openid_connect_provider.url, "https://", "")}:sub": "system:serviceaccount:${var.toolchain_namespace}:product-operator"
        }
      }
    }
  ]
}
EOF
}

#probably too permissive
resource "aws_iam_role_policy" "product-operator" {
  name = "${var.cluster}-product-operator"
  role = aws_iam_role.product_operator_service_account.name
  
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
        ],
        "Resource": "*"
    }
  ]
} 
EOF
}
