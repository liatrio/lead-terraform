data "aws_caller_identity" "current" {
}

locals {
  userdata = <<EOF
echo '{"registry-mirrors": [${var.docker_registry_mirror != "" ? format("\"%s\"", var.docker_registry_mirror) : ""}]}' | cat /etc/docker/daemon.json - | jq -s '.[0] * .[1]' > /tmp/daemon.json
mv /tmp/daemon.json /etc/docker/daemon.json
systemctl restart docker

# this is a dumb hack to enable the docker bridge on managed node groups
# normally you'd use "bootstrap_extra_args" with regular worker groups in order to specify "--enable-docker-bridge 'true'"
# however, MNGs don't support this yet without running a custom AMI, which would allow you to invoke the bootstrap script yourself
# this sed command simply modifies this line of the bootstrap script: https://github.com/awslabs/amazon-eks-ami/blob/d03b2ac370f473ddfd1f2d11d5ba93ecb5c1ec19/files/bootstrap.sh#L114
# TODO: remove this hack once MNGs support bootstrap_extra_args
sed -i 's/ENABLE_DOCKER_BRIDGE:.*/ENABLE_DOCKER_BRIDGE:-true}\"/' /etc/eks/bootstrap.sh
EOF

  tags = {
    "Cluster" = var.cluster
  }

  default_roles = [
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Administrator"
      username = "administrator"
      groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Developer"
      username = "developer"
      groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.workspace_role.name}"
      username = "user"
      groups   = ["system:authenticated"]
    },
  ]

  codebuild_roles = var.enable_aws_code_services ? [
    {
      rolearn  = var.codebuild_role
      username = "codebuild"
      groups   = ["system:authenticated"]
    }
  ] : []
}

data "aws_vpc" "lead_vpc" {
  tags = {
    Name = var.vpc_name
  }
}

data "aws_subnets" "eks_masters" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.lead_vpc.id]
  }

  filter {
    name   = "cidr-block"
    values = ["*/24"]
  }

  tags = {
    subnet-kind = "private"
  }
}

data "aws_subnets" "eks_workers" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.lead_vpc.id]
  }

  filter {
    name   = "cidr-block"
    values = ["*/18"]
  }

  tags = {
    subnet-kind = "private"
  }
}

resource "aws_kms_key" "eks_encryption_kms" {
  description         = "Used to encrypt EKS secrets"
  enable_key_rotation = true
}

resource "aws_security_group" "worker" {
  name_prefix = "${var.cluster}-worker"
  vpc_id      = data.aws_vpc.lead_vpc.id
  # description = "worker based security groups"

  ingress {
    # description = "Allow SSH access"
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = concat([data.aws_vpc.lead_vpc.cidr_block], var.enable_ssh_access ? [var.internal_vpn_subnet] : [])
  }
  ingress {
    # description = "Allow HTTPS access"
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    security_groups = [aws_security_group.elb.id]
  }
}
#tfsec:ignore:aws-vpc-no-public-ingress-sgr
resource "aws_security_group" "elb" {
  name_prefix = "${var.cluster}-ingress-elb"
  vpc_id      = data.aws_vpc.lead_vpc.id
  # description = "Allow HTTPS access"

  tags = {
    Name    = "${var.cluster}-ingress-elb"
    Cluster = var.cluster
    Type    = "ingress-elb"
  }

  ingress {
    # description = "Allow HTTP access"
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  ingress {
    # description = "Allow HTTPS access"
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.20.5"

  cluster_name    = var.cluster
  cluster_version = var.cluster_version
  subnet_ids      = sort(data.aws_subnets.eks_masters.ids)
  vpc_id          = data.aws_vpc.lead_vpc.id

  iam_role_name            = "lead"
  iam_role_use_name_prefix = true

  cluster_additional_security_group_ids = [aws_security_group.worker.id]
  cluster_security_group_additional_rules = {
    ingress_vpc_for_internal_vpn = {
      description = "ingress rules for internal vpn"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
      cidr_blocks = distinct([
        var.internal_vpn_subnet,
        var.shared_svc_subnet,
        data.aws_vpc.lead_vpc.cidr_block // anything running within the lead VPC, such as codebuild projects
      ])
    }
    egress_nodes_ephemeral_ports_tcp = {
      description                = "Egress to Nodes"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }

  # Extend node-to-node security group rules
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }

    ingress_master_to_node = {
      description                   = "Allow inbound from Cluster"
      from_port                     = 1025
      to_port                       = 65535
      protocol                      = "tcp"
      type                          = "ingress"
      source_cluster_security_group = true
    }

    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  manage_aws_auth_configmap     = true
  aws_auth_roles                = concat(local.default_roles, local.codebuild_roles, var.additional_mapped_roles)
  iam_role_permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/Developer"
  enable_irsa                   = true

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = var.enable_public_endpoint
  cluster_enabled_log_types       = ["api", "authenticator", "audit", "scheduler", "controllerManager"]

  cluster_encryption_config = [{
    provider_key_arn = aws_kms_key.eks_encryption_kms.arn
    resources        = ["secrets"]
  }]

  tags = {
    "Cluster" = var.cluster
  }

  eks_managed_node_group_defaults = {
    # the values below are the defaults for spot nodes, which will only be overridden by the essential node group
    capacity_type  = "SPOT"
    desired_size   = var.spot_asg_desired_capacity
    min_size       = var.spot_asg_min_size
    max_size       = var.spot_asg_max_size
    instance_types = var.spot_instance_types

    update_config = {
      max_unavailable_percentage = 50
    }

    vpc_security_group_ids        = [aws_security_group.worker.id]
    create_launch_template        = true
    pre_bootstrap_user_data       = local.userdata
    enable_monitoring             = true
    key_name                      = var.key_name
    cluster_version               = var.cluster_version
    disk_size                     = var.root_volume_size
    iam_role_permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/Developer"

  }

  eks_managed_node_groups = {
    "essential" = {
      name            = "${var.cluster}-essential"
      use_name_prefix = true
      subnet_ids      = sort(data.aws_subnets.eks_workers.ids)
      labels = {
        "node.liatr.io/lifecycle" = "essential"
      }

      taints = [
        {
          key    = var.essential_taint_key
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      ]

      capacity_type  = "ON_DEMAND"
      desired_size   = var.essential_asg_desired_capacity
      min_size       = var.essential_asg_min_size
      max_size       = var.essential_asg_max_size
      instance_types = [var.essential_instance_type]
    }
    "spot0" = {
      name            = "${var.cluster}-spot0"
      use_name_prefix = true
      subnet_ids      = [sort(data.aws_subnets.eks_workers.ids)[0]]
      labels = {
        "node.liatr.io/lifecycle" = "preemptible"
      }
    }
    "spot1" = {
      name            = "${var.cluster}-spot1"
      use_name_prefix = true
      subnet_ids      = [sort(data.aws_subnets.eks_workers.ids)[1]]
      labels = {
        "node.liatr.io/lifecycle" = "preemptible"
      }
    }
    "spot2" = {
      name            = "${var.cluster}-spot2"
      use_name_prefix = true
      subnet_ids      = [sort(data.aws_subnets.eks_workers.ids)[2]]
      labels = {
        "node.liatr.io/lifecycle" = "preemptible"
      }
    }
  }
}

#---
# All these are necessary since defining those blocks within
# the aws_s3_bucket resource is deprecated. Terraform reccomends
# defining resources referencing the bucket instead.
resource "aws_s3_bucket" "tfstates" {
  bucket = "lead-sdm-operators-${data.aws_caller_identity.current.account_id}-${var.cluster}.liatr.io"

  tags = {
    Name      = "SDM Operator Terraform States"
    ManagedBy = "Terraform"
    Cluster   = var.cluster
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstates_encryption" {
  bucket = aws_s3_bucket.tfstates.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.tfstates_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_acl" "tfstates_acl" {
  bucket = aws_s3_bucket.tfstates.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_versioning" "tfstates_versioning" {
  bucket = aws_s3_bucket.tfstates.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "tfstates_logging" {
  bucket = aws_s3_bucket.tfstates.id

  target_bucket = var.s3_logging_id
  target_prefix = "TFStateLogs/"
}

resource "aws_kms_key" "tfstates_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

# Used to restrict public access and block users from creating policies to enable it
resource "aws_s3_bucket_public_access_block" "tfstates_block" {
  bucket                  = aws_s3_bucket.tfstates.id
  block_public_acls       = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  block_public_policy     = true
}

resource "aws_eks_addon" "addon" {
  for_each          = var.cluster_addons
  cluster_name      = module.eks.cluster_id
  addon_name        = each.key
  addon_version     = each.value
  resolve_conflicts = "OVERWRITE"
  depends_on = [
    module.eks
  ]
}

resource "aws_iam_role_policy_attachment" "eks_worker_ssm_policy_attachment" {
  for_each   = module.eks.eks_managed_node_groups
  role       = each.value.iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

