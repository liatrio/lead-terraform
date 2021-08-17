module "cluster_autoscaler_iam" {
  source = "../../../../modules/environment/aws/iam/cluster-autoscaler"

  cluster                     = module.eks.cluster_id
  namespace                   = var.system_namespace
  openid_connect_provider_arn = module.eks.aws_iam_openid_connect_provider.arn
  openid_connect_provider_url = module.eks.aws_iam_openid_connect_provider.url
}

data "aws_route53_zone" "private_internal_services_liatr_io" {
  name         = "${var.internal_cluster_domain}."
  private_zone = true
}

data "aws_route53_zone" "public_internal_services_liatr_io" {
  name = "${var.internal_cluster_domain}."
}

data "aws_route53_zone" "services_liatr_io" {
  name = "${var.cluster_domain}."
}

module "external_dns_iam" {
  source = "../../../../modules/environment/aws/iam/external-dns"

  cluster                     = module.eks.cluster_id
  namespace                   = var.system_namespace
  openid_connect_provider_arn = module.eks.aws_iam_openid_connect_provider.arn
  openid_connect_provider_url = module.eks.aws_iam_openid_connect_provider.url
  route53_zone_ids = [
    data.aws_route53_zone.private_internal_services_liatr_io.zone_id,
  ]
}

module "external_dns_iam_public" {
  source = "../../../../modules/environment/aws/iam/external-dns"

  cluster                     = module.eks.cluster_id
  namespace                   = var.system_namespace
  openid_connect_provider_arn = module.eks.aws_iam_openid_connect_provider.arn
  openid_connect_provider_url = module.eks.aws_iam_openid_connect_provider.url
  route53_zone_ids = [
    data.aws_route53_zone.services_liatr_io.zone_id
  ]
  service_account_name = "external-dns-public"
}

module "cert_manager_iam" {
  source = "../../../../modules/environment/aws/iam/cert-manager"

  cluster                     = module.eks.cluster_id
  namespace                   = var.system_namespace
  openid_connect_provider_arn = module.eks.aws_iam_openid_connect_provider.arn
  openid_connect_provider_url = module.eks.aws_iam_openid_connect_provider.url
}

resource "aws_iam_role" "rode_service_account" {
  name = "${var.cluster_name}_rode_service_account"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${module.eks.aws_iam_openid_connect_provider.arn}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${replace(module.eks.aws_iam_openid_connect_provider.url, "https://", "")}:sub": "system:serviceaccount:rode:rode"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "rode" {
  name = "${var.cluster_name}-rode"
  role = aws_iam_role.rode_service_account.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sqs:CreateQueue",
                "sqs:SetQueueAttributes",
                "sqs:GetQueueUrl",
                "sqs:GetQueueAttributes",
                "sqs:ReceiveMessage",
                "sqs:DeleteMessage"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "events:PutTargets",
                "events:PutRule"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

module "docker_registry_iam" {
  source = "../../../../modules/environment/aws/iam/docker-registry"

  cluster = module.eks.cluster_id
}
