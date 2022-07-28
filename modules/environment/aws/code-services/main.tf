data "aws_vpc" "lead_vpc" {
  tags = {
    Name = var.vpc_name
  }
}

data "aws_subnets" "eks_workers" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.lead_vpc.id]
  }

  filter {
    name = "cidr-block"
    values = [
      "*/18"
    ]
  }

  tags = {
    "subnet-kind" = "private"
  }
}

resource "aws_s3_bucket" "code_services_bucket" {
  bucket = "code-services-${var.account_id}-${var.cluster}"

  #Enables encryption using customer managed keys
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.example.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "aws_s3_bucket_versioning" "code_services_versioning" {
  bucket = aws_s3_bucket.code_services_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "tfstates_logging" {
  bucket = aws_s3_bucket.code_services_bucket.id

  target_bucket = "code-services-${var.account_id}-${var.cluster}"
  target_prefix = "CodeServicesLogs/"
}

# Used to restrict public access and block users from creating policies to enable it
resource "aws_s3_bucket_public_access_block" "code_services_block" {
  bucket                  = aws_s3_bucket.code_services_bucket.id
  block_public_acls       = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  block_public_policy     = true
}

resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-role-${var.cluster}"

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
      "Action": [
        "ec2:CreateNetworkInterfacePermission"
      ],
      "Resource": "arn:aws:ec2:${var.region}:${var.account_id}:network-interface/*",
      "Condition": {
        "StringEquals": {
          "ec2:Subnet": ${jsonencode(formatlist("arn:aws:ec2:${var.region}:${var.account_id}:subnet/%s", data.aws_subnets.eks_workers.ids))},
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
        "${aws_s3_bucket.code_services_bucket.arn}",
        "${aws_s3_bucket.code_services_bucket.arn}/*"
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
  name = "codepipeline-role-${var.cluster}"

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
  name = "codepipeline_policy-${var.cluster}"
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

#tfsec:ignore:aws-sqs-enable-queue-encryption
resource "aws_sqs_queue" "code_services_queue" {
  name                      = "code_services-${var.account_id}-${var.cluster}"
  message_retention_seconds = 86400
}

resource "aws_cloudwatch_event_rule" "code_services_event_rule" {
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
  rule = aws_cloudwatch_event_rule.code_services_event_rule.name
  arn  = aws_sqs_queue.code_services_queue.arn
}

resource "aws_sqs_queue_policy" "code_services_queue_policy" {
  queue_url = aws_sqs_queue.code_services_queue.id

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

resource "aws_iam_role" "event_mapper_role" {
  name = "${var.cluster}_event_mapper_role"

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
  name = "${var.cluster}_event_mapper_role_policy"

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
      "Resource": "${aws_sqs_queue.code_services_queue.arn}"
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
  policy_arn = aws_iam_policy.event_mapper_role_policy.arn
  role       = aws_iam_role.event_mapper_role.name
}

#tfsec:ignore:aws-vpc-add-description-to-security-group
#tfsec:ignore:aws-vpc-no-public-egress-sg
resource "aws_security_group" "codebuild_security_group" {
  name   = "codebuild-egress"
  vpc_id = data.aws_vpc.lead_vpc.id

  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}
