resource "aws_s3_bucket" "velero" {
  count  = var.enable_velero ? 1 : 0
  bucket = "velero-${var.account_id}-${var.cluster_name}"
  acl    = "private"
}

resource "aws_iam_user" "velero" {
  count  = var.enable_velero ? 1 : 0
  name = var.velero_user
}

resource "aws_iam_user_policy" "velero" {
  count  = var.enable_velero ? 1 : 0
  name = var.velero_user
  user = aws_iam_user.velero.name

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
                "arn:aws:s3:::${aws_s3_bucket.velero.bucket}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.velero.bucket}"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_access_key" "velero" {
  count  = var.enable_velero ? 1 : 0
  user    = aws_iam_user.velero.0.name
}

