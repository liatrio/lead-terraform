data "aws_caller_identity" "current" {
}

locals {
  worker_groups = [
    {
      instance_type         = var.instance_type
      subnets               = module.vpc.private_subnets[0]
      asg_min_size          = var.asg_min_size
      asg_desired_capacity  = var.asg_desired_capacity
      asg_max_size          = var.asg_max_size
      bootstrap_extra_args  = "--enable-docker-bridge 'true'"
      key_name              = var.key_name
      autoscaling_enabled   = true
      protect_from_scale_in = true
    },
    {
      instance_type         = var.instance_type
      subnets               = module.vpc.private_subnets[1]
      asg_min_size          = var.asg_min_size
      asg_desired_capacity  = var.asg_desired_capacity
      asg_max_size          = var.asg_max_size
      bootstrap_extra_args  = "--enable-docker-bridge 'true'"
      key_name              = var.key_name
      autoscaling_enabled   = true
      protect_from_scale_in = true
    },
    {
      instance_type         = var.instance_type
      subnets               = module.vpc.private_subnets[2]
      asg_min_size          = var.asg_min_size
      asg_desired_capacity  = var.asg_desired_capacity
      asg_max_size          = var.asg_max_size
      bootstrap_extra_args  = "--enable-docker-bridge 'true'"
      key_name              = var.key_name
      autoscaling_enabled   = true
      protect_from_scale_in = true
    },
  ]

  map_roles = [
    {
      role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Administrator"
      username = "administrator"
      group    = "system:masters"
    },
    {
      role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Developer"
      username = "developer"
      group    = "system:masters"
    },
    {
      role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.workspace_role.name}"
      username = "user"
      group    = "system:authenticated"
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
  version                              = "5.0.0"
  cluster_version                      = "1.12"
  cluster_name                         = var.cluster
  subnets                              = [module.vpc.private_subnets]
  tags                                 = local.tags
  vpc_id                               = module.vpc.vpc_id
  worker_groups                        = local.worker_groups
  worker_additional_security_group_ids = [aws_security_group.worker.id]
  map_roles                            = local.map_roles
  worker_ami_name_filter               = var.worker_ami_name_filter
  write_kubeconfig                     = false
  permissions_boundary                 = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/Developer"
  workers_additional_policies          = [aws_iam_policy.worker_policy.arn]
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
       "route53:ListHostedZones"
     ],
     "Resource": ["*"]
   },
   {
     "Effect": "Allow",
     "Action": [
       "cloud9:DescribeEnvironmentMemberships", "cloud9:DescribeEnvironments"
     ],
     "Resource": ["*"]
   }
 ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "worker_ecr_role_attachment" {
  role = module.eks.worker_iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
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


permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/Developer"
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

