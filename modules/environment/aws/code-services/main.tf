data "aws_vpc" "lead_vpc" {
  tags = {
    Name = var.vpc_name
  }
}

data "aws_subnet_ids" "eks_workers" {
  vpc_id = data.aws_vpc.lead_vpc.id

  filter {
    name   = "tag:subnet-kind"
    values = [
      "private"
    ]
  }

  filter {
    name   = "cidr-block"
    values = [
      "*/18"
    ]
  }
}

resource "aws_s3_bucket" "code_services_bucket" {
  count  = var.enable_aws_code_services ? 1 : 0
  bucket = "code-services-${var.account_id}-${var.cluster}"
  versioning {
    enabled = true
  }

}

resource "aws_iam_role" "codebuild_role" {
  count = var.enable_aws_code_services ? 1 : 0
  name  = "codebuild-role-${var.cluster}"

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
  count = var.enable_aws_code_services ? 1 : 0
  role  = aws_iam_role.codebuild_role[0].name

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
      "Action": [
        "ec2:CreateNetworkInterfacePermission"
      ],
      "Resource": "arn:aws:ec2:${var.region}:${var.account_id}:network-interface/*",
      "Condition": {
        "StringEquals": {
          "ec2:Subnet": ${jsonencode(formatlist("arn:aws:ec2:${var.region}:${var.account_id}:subnet/%s", data.aws_subnet_ids.eks_workers.ids))},
          "ec2:AuthorizedService": "codebuild.amazonaws.com"
        }
      }
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
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:PutImage"
      ],
      "Resource": [
          "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "eks:DescribeCluster"
      ],
      "Resource": [
          "*"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_role" "codepipeline_role" {
  count = var.enable_aws_code_services ? 1 : 0
  name  = "codepipeline-role-${var.cluster}"

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
  count = var.enable_aws_code_services ? 1 : 0
  name  = "codepipeline_policy-${var.cluster}"
  role  = aws_iam_role.codepipeline_role[0].id

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
  name        = "code_services-event-rule-${var.cluster}"
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
  count = var.enable_aws_code_services ? 1 : 0
  rule  = aws_cloudwatch_event_rule.code_services_event_rule[0].name
  arn   = aws_sqs_queue.code_services_queue[0].arn
}

resource "aws_sqs_queue_policy" "code_services_queue_policy" {
  count     = var.enable_aws_code_services ? 1 : 0
  queue_url = aws_sqs_queue.code_services_queue[0].id

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

resource "aws_iam_role" "event_mapper_role" {
  count = var.enable_aws_code_services ? 1 : 0
  name  = "${var.cluster}_event_mapper_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${var.account_id}:oidc-provider/${replace(var.openid_connect_provider_url, "https://", "")}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${replace(var.openid_connect_provider_url, "https://", "")}:sub": "system:serviceaccount:${var.toolchain_namespace}:aws-event-mapper"
        }
      }
    }
  ]
}
EOF

  permissions_boundary = "arn:aws:iam::${var.account_id}:policy/Developer"
}

resource "aws_iam_policy" "event_mapper_role_policy" {
  count = var.enable_aws_code_services ? 1 : 0
  name  = "${var.cluster}_event_mapper_role_policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage"
      ],
      "Effect": "Allow",
      "Resource": "${aws_sqs_queue.code_services_queue[0].arn}"
    },
    {
      "Action": [
        "codepipeline:GetPipeline",
        "codepipeline:GetPipelineExecution",
        "codepipeline:ListTagsForResource"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "codecommit:GetCommit"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "event_mapper_role_policy_attachment" {
  count      = var.enable_aws_code_services ? 1 : 0
  policy_arn = aws_iam_policy.event_mapper_role_policy[0].arn
  role       = aws_iam_role.event_mapper_role[0].name
}

resource "aws_security_group" "codebuild_security_group" {
  count  = var.enable_aws_code_services ? 1 : 0
  name   = "codebuild-egress"
  vpc_id = data.aws_vpc.lead_vpc.id

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}
