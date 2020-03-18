resource "aws_s3_bucket" "code_services_bucket" {
  count  = var.enable_aws_code_services ? 1 : 0
  bucket = "code-services-${var.account_id}-${var.cluster}"
  region = var.region
  versioning {
    enabled = true
  }

}

resource "aws_iam_role" "codebuild_role" {
  count  = var.enable_aws_code_services ? 1 : 0
  name   = "codebuild-role"

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
  count  = var.enable_aws_code_services ? 1 : 0
  role   = aws_iam_role.codebuild_role[0].name

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
        "${aws_s3_bucket.code_services_bucket[0].arn}",
        "${aws_s3_bucket.code_services_bucket[0].arn}/*"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_role" "codepipeline_role" {
  count  = var.enable_aws_code_services ? 1 : 0
  name   = "codepipeline-role"

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
  count  = var.enable_aws_code_services ? 1 : 0
  name   = "codepipeline_policy"
  role   = aws_iam_role.codepipeline_role[0].id

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
        "${aws_s3_bucket.code_services_bucket[0].arn}",
        "${aws_s3_bucket.code_services_bucket[0].arn}/*"
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
  count                     = var.enable_aws_code_services ? 1 : 0
  name                      = "code_services-${var.account_id}-${var.cluster}"
  message_retention_seconds = 86400
}

resource "aws_cloudwatch_event_rule" "code_services_event_rule" {
  count       = var.enable_aws_code_services ? 1 : 0
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
  count     = var.enable_aws_code_services ? 1 : 0
  rule      = "${aws_cloudwatch_event_rule.code_services_event_rule[0].name}"
  arn       = "${aws_sqs_queue.code_services_queue[0].arn}"
}

resource "aws_sqs_queue_policy" "code_services_queue_policy" {
  count     = var.enable_aws_code_services ? 1 : 0
  queue_url = "${aws_sqs_queue.code_services_queue[0].id}"

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
      "Resource": "${aws_sqs_queue.code_services_queue[0].arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_cloudwatch_event_rule.code_services_event_rule[0].arn}"
        }
      }
    }
  ]
}
POLICY
}
