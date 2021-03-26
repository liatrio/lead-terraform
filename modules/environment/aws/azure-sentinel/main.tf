data "aws_iam_policy_document" "azure_sentinal_assume_role_policy" {
  statement {
    sid = "AzureSentinelAssumeRole"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "AWS"
      identifiers = [
        format("arn:aws:iam::%s:root", var.azure_sentinel_aws_account_id)
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [
        var.azure_sentinel_external_id
      ]
    }
  }

}

resource "aws_iam_role" "azure_sentinel_role" {
  name               = "azure-sentinel-${var.cluster}"
  assume_role_policy = data.aws_iam_policy_document.azure_sentinal_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "azure_sentinel_role_policy" {
  role       = aws_iam_role.azure_sentinel_role.id
  policy_arn = "arn:aws:iam::aws:policy/AWSCloudTrailReadOnlyAccess"
}
