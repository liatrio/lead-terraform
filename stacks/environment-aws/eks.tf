data "aws_caller_identity" "current" {
}

locals {
  ssm_init = <<EOF
yum install -y amazon-ssm-agent
systemctl start amazon-ssm-agent
systemctl enable amazon-ssm-agent
EOF


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
  private_subnets    = ["10.0.64.0/18", "10.0.128.0/18", "10.0.192.0/18"]
  public_subnets     = ["10.0.32.0/24", "10.0.33.0/24", "10.0.34.0/24"]
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
  source                               = "terraform-aws-modules/eks/aws"
  version                              = "7.0.0"
  cluster_version                      = "1.14"
  #cluster_enabled_log_types            = ["api","audit","authenticator","controllerManager","scheduler"]
  cluster_name                         = var.cluster
  subnets                              = module.vpc.private_subnets
  tags                                 = local.tags
  vpc_id                               = module.vpc.vpc_id
  worker_additional_security_group_ids = [aws_security_group.worker.id]
  map_roles                            = local.map_roles
  write_kubeconfig                     = false
  permissions_boundary                 = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${aws_iam_policy.workspace_role_boundary.name}"
  manage_worker_iam_resources          = true
  manage_worker_autoscaling_policy     = true
  attach_worker_autoscaling_policy     = false

  workers_additional_policies = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",

    // TODO: remove the following policy from the worker node role once terraform is bumped 
    //       to version that includes fix for: https://github.com/hashicorp/terraform/issues/22992
    aws_iam_policy.operator_jenkins.arn 
  ]

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
