resource "aws_s3_bucket" "velero" {
  bucket = "velero-${var.account_id}-${var.cluster_name}"
  acl    = "private"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_iam_user" "velero" {
  name  = var.velero_user
}

resource "aws_iam_user_policy" "velero" {
  name  = var.velero_user
  user  = aws_iam_user.velero.0.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeVolumes",
                "ec2:DescribeSnapshots",
                "ec2:CreateTags",
                "ec2:CreateVolume",
                "ec2:CreateSnapshot",
                "ec2:DeleteSnapshot"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:DeleteObject",
                "s3:PutObject",
                "s3:AbortMultipartUpload",
                "s3:ListMultipartUploadParts"
            ],
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.velero.0.bucket}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.velero.0.bucket}"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_access_key" "velero" {
  user  = aws_iam_user.velero.0.name
}

