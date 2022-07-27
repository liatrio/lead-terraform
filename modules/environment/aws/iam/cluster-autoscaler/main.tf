data "aws_caller_identity" "current" {
}

resource "aws_iam_role" "cluster_autoscaler_service_account" {
  name = "${var.cluster}_cluster_autoscaler_service_account"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${var.openid_connect_provider_arn}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${replace(var.openid_connect_provider_url, "https://", "")}:sub": "system:serviceaccount:${var.namespace}:cluster-autoscaler-aws-cluster-autoscaler"
        }
      }
    }
  ]
}
EOF

  permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/Developer"
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  role       = aws_iam_role.cluster_autoscaler_service_account.name
  policy_arn = aws_iam_policy.cluster_autoscaler.arn
}

resource "aws_iam_policy" "cluster_autoscaler" {
  name_prefix = "lead-cluster-autoscaler"
  description = "EKS cluster-autoscaler policy for cluster ${var.cluster}"
  policy      = data.aws_iam_policy_document.cluster_autoscaler.json
}

data "aws_iam_policy_document" "cluster_autoscaler" {
  statement {
    sid    = "clusterAutoscalerAll"
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "ec2:DescribeLaunchTemplateVersions"
    ]

    # We ignore the wildcard here so that we can auto-discover auto-scaling groups (ASG)
    #   There is a minimal iam policy version of the eks autoscaler but in addition to
    #   the lack of auto-discovery, "it restricts the IAM permissions to the node groups 
    #   the Cluster Autoscaler is configured to scale."
    #   Link to docs: https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/README.md#minimal-iam-permissions-policy

    #tfsec:ignore:aws-iam-no-policy-wildcards
    resources = [
      "*"
    ]
  }
}
