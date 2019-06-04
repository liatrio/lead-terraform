data "aws_caller_identity" "current" {}

locals {
  worker_groups = [
    {
      # This will launch an autoscaling group with only On-Demand instances
      instance_type        = "${var.instance_type}"
      subnets              = "${join(",", module.vpc.private_subnets)}"
      asg_desired_capacity = "${var.asg_desired_capacity}"
      bootstrap_extra_args = "--enable-docker-bridge 'true'"
      key_name             = "${var.key_name}"
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
  ]
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  version            = "1.14.0"
  name               = "${var.cluster}"
  cidr               = "10.0.0.0/16"
  azs                = ["${data.aws_availability_zones.available.names[0]}", "${data.aws_availability_zones.available.names[1]}", "${data.aws_availability_zones.available.names[2]}"]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true
  tags               = "${merge(local.tags, map("kubernetes.io/cluster/${var.cluster}", "shared"))}"
}

resource "aws_security_group" "worker" {
  name_prefix = "${var.cluster}-worker"
  vpc_id      = "${module.vpc.vpc_id}"

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

    security_groups = ["${aws_security_group.elb.id}"]
  }
}

resource "aws_security_group" "elb" {
  name_prefix = "${var.cluster}-ingress-elb"
  vpc_id      = "${module.vpc.vpc_id}"

  tags = {
    Name = "${var.cluster}-ingress-elb"
    Cluster = "${var.cluster}"
    Type = "ingress-elb"
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
  version                              = "4.0.2"
  cluster_version                      = "1.12"
  cluster_name                         = "${var.cluster}"
  subnets                              = ["${module.vpc.private_subnets}"]
  tags                                 = "${local.tags}"
  vpc_id                               = "${module.vpc.vpc_id}"
  worker_groups                        = "${local.worker_groups}"
  worker_group_count                   = "1"
  worker_additional_security_group_ids = ["${aws_security_group.worker.id}"]
  map_roles                            = "${local.map_roles}"
  map_roles_count                      = "${length(local.map_roles)}"
  worker_ami_name_filter               = "${var.worker_ami_name_filter}"
  write_kubeconfig                     = false
  permissions_boundary                 = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/Developer"
  workers_additional_policies          = ["${aws_iam_policy.worker_policy.arn}"]
  workers_additional_policies_count    = 1
}


resource "aws_iam_policy" "worker_policy" {
  name        = "${var.cluster}-worker-policy"

  policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Effect": "Allow",
     "Action": [
       "route53:ChangeResourceRecordSets"
     ],
     "Resource": [
       "arn:aws:route53:::hostedzone/*"
     ]
   },
   {
     "Effect": "Allow",
     "Action": [
       "route53:ListHostedZones",
       "route53:ListResourceRecordSets"
     ],
     "Resource": [
       "*"
     ]
   }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "worker_ecr_role_attachment" {
  role       = "${module.eks.worker_iam_role_name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}
