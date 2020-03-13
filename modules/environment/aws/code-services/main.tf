resource "aws_s3_bucket" "code_services_bucket" {
  bucket = "code_services-${var.account_id}-${var.cluster}"
  region = var.region
  versioning {
    enabled = true
  }

}

resource "aws_iam_role" "codebuild_role" {
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
        "${aws_s3_bucket.code_services_bucket.arn}",
        "${aws_s3_bucket.code_services_bucket.arn}/*"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_role" "codepipeline_role" {
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
        "${aws_s3_bucket.code_services_bucket.arn}",
        "${aws_s3_bucket.code_services_bucket.arn}/*"
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

resource "aws_sqs_queue" "code_services_queue" {
  name                      = "code_services-${var.account_id}-${var.cluster}"
  message_retention_seconds = 86400
}

resource "aws_cloudwatch_event_rule" "code_services_event_rule" {
  name        = "code_services-event-rule"
  description = "code_services-event-rule"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.codepipeline"
  ]
}
PATTERN
}

resource "aws_cloudwatch_event_target" "code_services_event_target" {
  rule      = "${aws_cloudwatch_event_rule.code_services_event_rule.name}"
  arn       = "${aws_sqs_queue.code_services_queue.arn}"
}

resource "aws_sqs_queue_policy" "code_services_queue_policy" {
  queue_url = "${aws_sqs_queue.code_services_queue.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "code_services-sqs-policy",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.code_services_queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_cloudwatch_event_rule.code_services_event_rule.arn}"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_iam_role" "product_operator_service_account" {
  name = "${var.cluster}_product_operator_service_account"

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
          "${replace(var.openid_connect_provider_url, "https://", "")}:sub": "system:serviceaccount:${var.toolchain_namespace}:product-operator"
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
