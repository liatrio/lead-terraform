data "aws_caller_identity" "current" {
}

locals {
  ssm_init = <<EOF
yum install -y amazon-ssm-agent
systemctl start amazon-ssm-agent
systemctl enable amazon-ssm-agent
EOF

  tags = {
    "Cluster" = var.cluster
  }

  map_roles = [
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
}

data "aws_availability_zones" "available" {
}


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.7.0"
  name    = var.cluster
  cidr    = "10.0.0.0/16"
  azs = [data.aws_availability_zones.available.names[0],
    data.aws_availability_zones.available.names[1],
    data.aws_availability_zones.available.names[2],
    data.aws_availability_zones.available.names[0],
    data.aws_availability_zones.available.names[1],
  data.aws_availability_zones.available.names[2]]
  // First 3 subnets are for EKS control plane, second 3 subnets are for nodes
  private_subnets = ["10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
    "10.0.64.0/18",
    "10.0.128.0/18",
  "10.0.192.0/18"]
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
      "10.0.0.0/16",
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
  source                                       = "terraform-aws-modules/eks/aws"
  version                                      = "10.0.0"
  cluster_version                              = var.cluster_version
  cluster_name                                 = var.cluster
  subnets                                      = [module.vpc.private_subnets[0], module.vpc.private_subnets[1], module.vpc.private_subnets[2]]
  tags                                         = local.tags
  vpc_id                                       = module.vpc.vpc_id
  worker_additional_security_group_ids         = [aws_security_group.worker.id]
  map_roles                                    = local.map_roles
  write_kubeconfig                             = var.write_kubeconfig
  permissions_boundary                         = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${aws_iam_policy.workspace_role_boundary.name}"
  manage_worker_iam_resources                  = true
  kubeconfig_aws_authenticator_additional_args = var.kubeconfig_aws_authenticator_additional_args
  enable_irsa  = false

  #cluster_enabled_log_types            = ["api","audit","authenticator","controllerManager","scheduler"]

  workers_additional_policies = concat(["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"], var.workers_additional_policies)

  workers_group_defaults = {
    tags = [
      {
        "key" = "kubernetes.io/cluster-autoscaler/enabled"
        "value" = "true"
        "propagate_at_launch" = true
      }
    ]
  }

  worker_groups = [
    {
      name                   = "essential0"
      instance_type          = var.essential_instance_type
      subnets                = [module.vpc.private_subnets[3], module.vpc.private_subnets[4], module.vpc.private_subnets[5]]
      asg_min_size           = var.essential_asg_min_size
      asg_desired_capacity   = var.essential_asg_desired_capacity
      asg_max_size           = var.essential_asg_max_size
      asg_recreate_on_change = true
      bootstrap_extra_args   = "--enable-docker-bridge 'true'"
      key_name               = var.key_name
      autoscaling_enabled    = true
      protect_from_scale_in  = var.protect_from_scale_in
      enabled_metrics        = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
      pre_userdata           = local.ssm_init
      kubelet_extra_args     = "--node-labels=kubernetes.io/lifecycle=essential --register-with-taints=${var.essential_taint_key}=true:NoSchedule"
    }
  ]

  worker_groups_launch_template = [
    {
      name                                     = "preemptible0"
      override_instance_types                  = var.preemptible_instance_types
      subnets                                  = [module.vpc.private_subnets[3]]
      asg_min_size                             = var.preemptible_asg_min_size
      asg_desired_capacity                     = var.preemptible_asg_desired_capacity
      asg_max_size                             = var.preemptible_asg_max_size
      asg_recreate_on_change                   = true
      bootstrap_extra_args                     = "--enable-docker-bridge 'true'"
      key_name                                 = var.key_name
      autoscaling_enabled                      = true
      protect_from_scale_in                    = var.protect_from_scale_in
      enabled_metrics                          = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
      pre_userdata                             = local.ssm_init
      kubelet_extra_args                       = "--node-labels=kubernetes.io/lifecycle=preemptible"
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = var.on_demand_percentage
    },
    {
      name                                     = "preemptible1"
      override_instance_types                  = var.preemptible_instance_types
      subnets                                  = [module.vpc.private_subnets[4]]
      asg_min_size                             = var.preemptible_asg_min_size
      asg_desired_capacity                     = var.preemptible_asg_desired_capacity
      asg_max_size                             = var.preemptible_asg_max_size
      asg_recreate_on_change                   = true
      bootstrap_extra_args                     = "--enable-docker-bridge 'true'"
      key_name                                 = var.key_name
      autoscaling_enabled                      = true
      protect_from_scale_in                    = var.protect_from_scale_in
      enabled_metrics                          = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
      pre_userdata                             = local.ssm_init
      kubelet_extra_args                       = "--node-labels=kubernetes.io/lifecycle=preemptible"
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = var.on_demand_percentage
    },
    {
      name                                     = "preemptible2"
      override_instance_types                  = var.preemptible_instance_types
      subnets                                  = [module.vpc.private_subnets[5]]
      asg_min_size                             = var.preemptible_asg_min_size
      asg_desired_capacity                     = var.preemptible_asg_desired_capacity
      asg_max_size                             = var.preemptible_asg_max_size
      asg_recreate_on_change                   = true
      bootstrap_extra_args                     = "--enable-docker-bridge 'true'"
      key_name                                 = var.key_name
      autoscaling_enabled                      = true
      protect_from_scale_in                    = var.protect_from_scale_in
      enabled_metrics                          = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
      pre_userdata                             = local.ssm_init
      kubelet_extra_args                       = "--node-labels=kubernetes.io/lifecycle=preemptible"
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = var.on_demand_percentage
    },
  ]
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
    Cluster   = "${var.cluster}"
  }
}
