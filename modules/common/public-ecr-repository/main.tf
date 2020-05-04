resource "aws_ecr_repository" "repo" {
  count = var.enabled ? 1 : 0
  name  = var.name
}

resource "aws_ecr_repository_policy" "policy" {
  count      = var.enabled ? 1 : 0
  repository = aws_ecr_repository.repo[0].name
  policy     = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "${aws_ecr_repository.repo[0].name}-public-access",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:DescribeImages",
                "ecr:ListTagsForResource",
                "ecr:BatchCheckLayerAvailability"
            ]
        }
    ]
}
EOF
}
