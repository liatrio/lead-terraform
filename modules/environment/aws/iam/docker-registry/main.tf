#tfsec:ignore:aws-s3-enable-bucket-logging
#tfsec:ignore:aws-s3-specify-public-access-block
#tfsec:ignore:aws-s3-enable-bucket-encryption
#tfsec:ignore:aws-s3-enable-versioning
resource "aws_s3_bucket" "docker_registry" {
  bucket = "docker-registry-storage-${var.cluster}"
}

resource "aws_iam_user" "docker_registry" {
  name = "docker-registry-${var.cluster}"
}

resource "aws_iam_user_policy" "docker_registry" {
  user   = aws_iam_user.docker_registry.name
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetBucketLocation",
        "s3:ListBucketMultipartUploads"
      ],
      "Resource": "${aws_s3_bucket.docker_registry.arn}"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:ListMultipartUploadParts",
        "s3:AbortMultipartUpload"
      ],
      "Resource": "${aws_s3_bucket.docker_registry.arn}/*"
    }
  ]
}
EOF
}

resource "aws_iam_access_key" "docker_registry" {
  user = aws_iam_user.docker_registry.name
}
