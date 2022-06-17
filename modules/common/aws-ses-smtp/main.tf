data "aws_caller_identity" "current" {
}

resource "random_pet" "ses_smtp" {
  keepers = {
    name = var.name
  }
}

resource "aws_iam_user" "ses_smtp" {
  name                 = "${var.name}-${random_pet.ses_smtp.id}"
  permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/Developer"
}

resource "aws_iam_access_key" "ses_smtp" {
  user = aws_iam_user.ses_smtp.name
}

#tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_user_policy" "ses_smtp_send" {
  name = "AllowSendingEmail"
  user = aws_iam_user.ses_smtp.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": "*",
      "Action":[
        "SES:SendEmail",
        "SES:SendRawEmail"
      ],
      "Condition":{
        "StringLike":{
          "ses:FromDisplayName":"${var.from_name}",
          "ses:FromAddress":"${var.from_address}",
          "ses:FeedbackAddress":"${var.reply_address}"
        }
      }
    }
  ]
}
EOF
}
