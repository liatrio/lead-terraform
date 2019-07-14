resource "random_pet" "ses_smtp" {
  keepers = {
    name = "${var.name}"
  }
}

resource "aws_iam_user" "ses_smtp" {
  name = "${var.name}-${random_pet.ses_smtp.id}"
}

resource "aws_iam_access_key" "ses_smtp" {
  user = "${aws_iam_user.ses_smtp.name}"
}

resource "aws_iam_user_policy" "ses_smtp_send" {
  name = "AllowSendingEmail"
  user = "${aws_iam_user.ses_smtp.name}"

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