data "aws_caller_identity" "current" {
}

locals {
  ssm_init = <<EOF
yum install -y amazon-ssm-agent
systemctl start amazon-ssm-agent
systemctl enable amazon-ssm-agent
EOF

  worker_groups = [
    {
      name                  = "essential0"
      instance_type         = var.essential_instance_type
      subnets               = module.vpc.private_subnets
      asg_min_size          = var.essential_asg_min_size
      asg_desired_capacity  = var.essential_asg_desired_capacity
      asg_max_size          = var.essential_asg_max_size
      asg_recreate_on_change= true
      bootstrap_extra_args  = "--enable-docker-bridge 'true'"
      key_name              = var.key_name
      autoscaling_enabled   = true
      protect_from_scale_in = true
      enabled_metrics       = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
      pre_userdata          = local.ssm_init
      kubelet_extra_args    = "--node-labels=kubernetes.io/lifecycle=essential --register-with-taints=${var.essential_taint_key}=true:NoSchedule"
    }
  ]

  worker_groups_launch_template = [
    {
      name                    = "preemptible0"
      override_instance_types = var.instance_types
      subnets                 = [module.vpc.private_subnets[0]]
      asg_min_size            = var.asg_min_size
      asg_desired_capacity    = var.asg_desired_capacity
      asg_max_size            = var.asg_max_size
      asg_recreate_on_change  = true
      bootstrap_extra_args    = "--enable-docker-bridge 'true'"
      key_name                = var.key_name
      autoscaling_enabled     = true
      protect_from_scale_in   = true
      enabled_metrics         = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]      
      pre_userdata            = local.ssm_init
      kubelet_extra_args      = "--node-labels=kubernetes.io/lifecycle=preemptible"
      on_demand_base_capacity = 0
      on_demand_percentage_above_base_capacity = var.on_demand_percentage
    },
    {
      name                    = "preemptible1"
      override_instance_types = var.instance_types
      subnets                 = [module.vpc.private_subnets[1]]
      asg_min_size            = var.asg_min_size
      asg_desired_capacity    = var.asg_desired_capacity
      asg_max_size            = var.asg_max_size
      asg_recreate_on_change  = true
      bootstrap_extra_args    = "--enable-docker-bridge 'true'"
      key_name                = var.key_name
      autoscaling_enabled     = true
      protect_from_scale_in   = true
      enabled_metrics         = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]      
      pre_userdata            = local.ssm_init
      kubelet_extra_args      = "--node-labels=kubernetes.io/lifecycle=preemptible"
      on_demand_base_capacity = 0
      on_demand_percentage_above_base_capacity = var.on_demand_percentage
    },
    {
      name                    = "preemptible2"
      override_instance_types = var.instance_types
      subnets                 = [module.vpc.private_subnets[2]]
      asg_min_size            = var.asg_min_size
      asg_desired_capacity    = var.asg_desired_capacity
      asg_max_size            = var.asg_max_size
      asg_recreate_on_change  = true
      bootstrap_extra_args    = "--enable-docker-bridge 'true'"
      key_name                = var.key_name
      autoscaling_enabled     = true
      protect_from_scale_in   = true
      enabled_metrics         = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]      
      pre_userdata            = local.ssm_init
      kubelet_extra_args      = "--node-labels=kubernetes.io/lifecycle=preemptible"
      on_demand_base_capacity = 0
      on_demand_percentage_above_base_capacity = var.on_demand_percentage
    },
  ]

  map_roles = [
    {
      rolearn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Administrator"
      username = "administrator"
      groups   = ["system:masters"]
    },
    {
      rolearn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Developer"
      username = "developer"
      groups   = ["system:masters"]
    },
    {
      rolearn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.workspace_role.name}"
      username = "user"
      groups   = ["system:authenticated"]
    },
  ]
}

data "aws_availability_zones" "available" {
}


module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  version            = "2.7.0"
  name               = var.cluster
  cidr               = "10.0.0.0/16"
  azs                = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1], data.aws_availability_zones.available.names[2]]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true
  tags = merge(
    local.tags,
    {
      "kubernetes.io/cluster/${var.cluster}" = "shared"
    },
  )
}

resource "aws_security_group" "worker" {
  name_prefix = "${var.cluster}-worker"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }
  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    security_groups = [aws_security_group.elb.id]
  }
}

resource "aws_security_group" "elb" {
  name_prefix = "${var.cluster}-ingress-elb"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name    = "${var.cluster}-ingress-elb"
    Cluster = var.cluster
    Type    = "ingress-elb"
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

module "eks" {
  source                               = "terraform-aws-modules/eks/aws"
  version                              = "6.0.0"
  cluster_version                      = "1.14"
  #cluster_enabled_log_types            = ["api","audit","authenticator","controllerManager","scheduler"]
  cluster_name                         = var.cluster
  subnets                              = module.vpc.private_subnets
  tags                                 = local.tags
  vpc_id                               = module.vpc.vpc_id
  worker_groups                        = local.worker_groups
  worker_groups_launch_template        = local.worker_groups_launch_template
  worker_additional_security_group_ids = [aws_security_group.worker.id]
  map_roles                            = local.map_roles
  write_kubeconfig                     = false
  permissions_boundary                 = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${aws_iam_policy.workspace_role_boundary.name}"
  workers_additional_policies          = [aws_iam_policy.worker_policy.arn]
}

resource "aws_iam_openid_connect_provider" "default" {
  url = module.eks.cluster_oidc_issuer_url

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = []
}

resource "aws_iam_policy" "worker_policy" {
  name = "${var.cluster}-worker-policy"

  policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Effect": "Allow",
     "Action": [
       "sts:AssumeRole"
     ],
     "Resource": [
       "${aws_iam_role.workspace_role.arn}"
     ]
   },
   {
     "Effect": "Allow",
     "Action": [
       "route53:ChangeResourceRecordSets",
       "route53:ListResourceRecordSets"
     ],
     "Resource": [
       "arn:aws:route53:::hostedzone/${aws_route53_zone.cluster_zone.zone_id}"
     ]
   },
   {
     "Effect": "Allow",
     "Action": [
       "route53:ListHostedZones",
       "route53:GetChange"
     ],
     "Resource": ["*"]
   },
   {
     "Effect": "Allow",
     "Action": [
       "cloud9:DescribeEnvironmentMemberships", "cloud9:DescribeEnvironments"
     ],
     "Resource": ["*"]
   },
   {
     "Effect": "Allow",
     "Action": [
                "s3:ListBucket",
                "s3:GetBucketVersioning",
                "s3:CreateBucket"
     ],
     "Resource": ["arn:aws:s3:::lead-sdm-operators-${data.aws_caller_identity.current.account_id}-${var.cluster}.liatr.io"]
   },
   {
     "Effect": "Allow",
     "Action": [
                "s3:PutObject",
                "s3:GetObject"
     ],
     "Resource": ["arn:aws:s3:::lead-sdm-operators-${data.aws_caller_identity.current.account_id}-${var.cluster}.liatr.io"]
   },
   {
     "Effect": "Allow",
     "Action": [
                "dynamodb:PutItem",
                "dynamodb:GetItem",
                "dynamodb:DescribeTable",
                "dynamodb:DeleteItem",
                "dynamodb:CreateTable",
                "dynamodb:TagResource"
     ],
     "Resource": ["arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/lead-sdm-operators-${var.cluster}"]
   }
 ]
}
EOF

}

resource "aws_s3_bucket" "tfstates" {
  bucket = "lead-sdm-operators-${data.aws_caller_identity.current.account_id}-${var.cluster}.liatr.io"
  acl    = "log-delivery-write"

  logging {
    target_bucket = "lead-sdm-operators-${data.aws_caller_identity.current.account_id}-${var.cluster}.liatr.io"
    target_prefix = "TFStateLogs/"
  }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "aws/s3"
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = {
    Name        = "SDM Operator Terraform States"
    ManagedBy   = "Terraform"
    Cluster     = "${var.cluster}"
  }
}

resource "aws_iam_role_policy_attachment" "worker_ecr_role_attachment" {
  role = module.eks.worker_iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}
resource "aws_iam_role_policy_attachment" "worker_ssm_role_attachment" {
  role = module.eks.worker_iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}
resource "aws_iam_role_policy_attachment" "worker_cw_role_attachment" {
  role = module.eks.worker_iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role" "workspace_role" {
  name = "${var.cluster}_workspace_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF


  permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${aws_iam_policy.workspace_role_boundary.name}"
}

resource "aws_iam_policy" "workspace_role_boundary" {
  name        = "${var.cluster}-workspace_role_boundary"
  description = "Permission boundaries for workspace role"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "NotAction": [
                "iam:*",
                "organizations:*",
                "account:*"
            ],
            "Resource": "*"
        },
        {
            "Action": [
                "iam:Get*",
                "iam:List*",
                "iam:CreateInstanceProfile",
                "iam:DeleteInstanceProfile",
                "iam:AddRoleToInstanceProfile",
                "iam:RemoveRoleFromInstanceProfile",
                "iam:CreatePolicy",
                "iam:CreateServiceLinkedRole",
                "iam:DeleteServiceLinkedRole",
                "organizations:DescribeOrganization",
                "account:ListRegions"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": [
                "iam:CreateRole",
                "iam:AttachRolePolicy",
                "iam:PutRolePermissionsBoundary"
            ],
            "Effect": "Allow",
            "Condition": {
                "StringEquals": {
                    "iam:PermissionsBoundary": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.cluster}-workspace_role_boundary}"
                }
            },
            "Resource": "*"
        },
        {
            "Action": [
                "iam:PassRole"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "workspace_role_attachment" {
  role       = aws_iam_role.workspace_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCloud9User"
}

resource "aws_iam_role_policy" "workspace_role_policy" {
  name = "workspace_access"
  role = aws_iam_role.workspace_role.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "eks:DescribeCluster"
      ],
      "Effect": "Allow",
      "Resource": "${module.eks.cluster_arn}"
    },
    {
      "Action": [
        "ec2:DescribeInstances","ec2:DescribeVolumesModifications"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "ec2:ModifyVolume"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
