data "aws_caller_identity" "current" {
}

locals {
  userdata = <<EOF
yum install -y amazon-ssm-agent
systemctl start amazon-ssm-agent
systemctl enable amazon-ssm-agent

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

data "aws_subnet_ids" "eks_masters" {
  vpc_id = data.aws_vpc.lead_vpc.id

  filter {
    name   = "tag:subnet-kind"
    values = ["private"]
  }

  filter {
    name   = "cidr-block"
    values = ["*/24"]
  }
}

data "aws_subnet_ids" "eks_workers" {
  vpc_id = data.aws_vpc.lead_vpc.id

  filter {
    name   = "tag:subnet-kind"
    values = ["private"]
  }

  filter {
    name   = "cidr-block"
    values = ["*/18"]
  }
}

resource "aws_security_group" "worker" {
  name_prefix = "${var.cluster}-worker"
  vpc_id      = data.aws_vpc.lead_vpc.id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = concat([data.aws_vpc.lead_vpc.cidr_block], var.enable_ssh_access ? [var.internal_vpn_subnet] : [])
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
  vpc_id      = data.aws_vpc.lead_vpc.id

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
  source  = "terraform-aws-modules/eks/aws"
  version = "17.18.0"

  cluster_name    = var.cluster
  cluster_version = var.cluster_version
  subnets         = sort(data.aws_subnet_ids.eks_masters.ids)
  vpc_id          = data.aws_vpc.lead_vpc.id

  worker_additional_security_group_ids         = [aws_security_group.worker.id]
  map_roles                                    = concat(local.default_roles, local.codebuild_roles, var.additional_mapped_roles)
  write_kubeconfig                             = var.write_kubeconfig
  permissions_boundary                         = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${aws_iam_policy.workspace_role_boundary.name}"
  manage_worker_iam_resources                  = true
  kubeconfig_aws_authenticator_additional_args = var.kubeconfig_aws_authenticator_additional_args
  enable_irsa                                  = true

  cluster_endpoint_private_access                = true
  cluster_endpoint_public_access                 = var.enable_public_endpoint
  cluster_create_endpoint_private_access_sg_rule = true
  cluster_endpoint_private_access_cidrs          = [
    "10.1.32.0/20", // internal VPN cidr
    data.aws_vpc.lead_vpc.cidr_block // anything running within the lead VPC, such as codebuild projects
  ]
  cluster_enabled_log_types                      = ["api", "controllerManager", "scheduler"]

  tags = {
    "Cluster" = var.cluster
  }

  node_groups_defaults = {
    create_launch_template = true
    pre_userdata           = local.userdata
    enable_monitoring      = true
    key_name               = var.key_name
    version                = var.cluster_version
    disk_size              = var.root_volume_size
    update_config          = {
      max_unavailable_percentage = 50
    }

    # the values below are the defaults for preemptible nodes, which will only be overridden by the essential node group
    capacity_type    = "SPOT"
    desired_capacity = var.preemptible_asg_desired_capacity
    min_capacity     = var.preemptible_asg_min_size
    max_capacity     = var.preemptible_asg_max_size
    instance_types   = var.preemptible_instance_types
  }

  node_groups = {
    "essential"    = {
      name_prefix = "${var.cluster}-essential"
      subnets     = sort(data.aws_subnet_ids.eks_workers.ids)
      k8s_labels  = {
        "node.liatr.io/lifecycle" = "essential"
      }

      taints = [
        {
          key    = var.essential_taint_key
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      ]

      capacity_type    = "ON_DEMAND"
      desired_capacity = var.essential_asg_desired_capacity
      min_capacity     = var.essential_asg_min_size
      max_capacity     = var.essential_asg_max_size
      instance_types   = [var.essential_instance_type]
    }
    "preemptible0" = {
      name_prefix = "${var.cluster}-preemptible0"
      subnets     = [sort(data.aws_subnet_ids.eks_workers.ids)[0]]
      k8s_labels  = {
        "node.liatr.io/lifecycle" = "preemptible"
      }
    }
    "preemptible1" = {
      name_prefix = "${var.cluster}-preemptible1"
      subnets     = [sort(data.aws_subnet_ids.eks_workers.ids)[1]]
      k8s_labels  = {
        "node.liatr.io/lifecycle" = "preemptible"
      }
    }
    "preemptible2" = {
      name_prefix = "${var.cluster}-preemptible2"
      subnets     = [sort(data.aws_subnet_ids.eks_workers.ids)[2]]
      k8s_labels  = {
        "node.liatr.io/lifecycle" = "preemptible"
      }
    }
  }
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
    Name      = "SDM Operator Terraform States"
    ManagedBy = "Terraform"
    Cluster   = var.cluster
  }
}
