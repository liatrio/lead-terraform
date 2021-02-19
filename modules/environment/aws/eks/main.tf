data "aws_caller_identity" "current" {
}

locals {
  userdata = <<EOF
yum install -y amazon-ssm-agent
systemctl start amazon-ssm-agent
systemctl enable amazon-ssm-agent

echo '{"registry-mirrors": [${ var.docker_registry_mirror != "" ? format("\"%s\"", var.docker_registry_mirror) : ""}]}' | cat /etc/docker/daemon.json - | jq -s '.[0] * .[1]' > /tmp/daemon.json
mv /tmp/daemon.json /etc/docker/daemon.json
systemctl reload docker
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

    cidr_blocks = [
      data.aws_vpc.lead_vpc.cidr_block,
      #"10.1.32.0/20", # internal VPN
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
  source                                       = "terraform-aws-modules/eks/aws"
  version                                      = "13.2.1"
  cluster_version                              = var.cluster_version
  cluster_name                                 = var.cluster
  subnets                                      = sort(data.aws_subnet_ids.eks_masters.ids)
  tags                                         = local.tags
  vpc_id                                       = data.aws_vpc.lead_vpc.id
  worker_additional_security_group_ids         = [aws_security_group.worker.id]
  map_roles                                    = concat(local.default_roles, local.codebuild_roles, var.additional_mapped_roles)
  write_kubeconfig                             = var.write_kubeconfig
  permissions_boundary                         = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${aws_iam_policy.workspace_role_boundary.name}"
  manage_worker_iam_resources                  = true
  kubeconfig_aws_authenticator_additional_args = var.kubeconfig_aws_authenticator_additional_args
  enable_irsa                                  = false

  cluster_endpoint_private_access                = true
  cluster_endpoint_public_access                 = var.enable_public_endpoint
  cluster_create_endpoint_private_access_sg_rule = true
  cluster_endpoint_private_access_cidrs = [
    "10.1.32.0/20",                  // internal VPN cidr
    data.aws_vpc.lead_vpc.cidr_block // anything running within the lead VPC, such as codebuild projects
  ]

  #cluster_enabled_log_types            = ["api","audit","authenticator","controllerManager","scheduler"]

  workers_additional_policies = concat(["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"], var.workers_additional_policies)

  workers_group_defaults = {
    tags = [
      {
        "key"                 = "kubernetes.io/cluster-autoscaler/enabled"
        "value"               = "true"
        "propagate_at_launch" = true
      }
    ]
  }

  worker_groups = [
    {
      name                   = "essential0"
      instance_type          = var.essential_instance_type
      subnets                = sort(data.aws_subnet_ids.eks_workers.ids)
      asg_min_size           = var.essential_asg_min_size
      asg_desired_capacity   = var.essential_asg_desired_capacity
      asg_max_size           = var.essential_asg_max_size
      asg_recreate_on_change = true
      bootstrap_extra_args   = "--enable-docker-bridge 'true'"
      key_name               = var.key_name
      autoscaling_enabled    = true
      protect_from_scale_in  = var.protect_from_scale_in
      enabled_metrics        = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
      pre_userdata           = local.userdata
      kubelet_extra_args     = "--node-labels=node.kubernetes.io/lifecycle=essential --register-with-taints=${var.essential_taint_key}=true:NoSchedule"
      root_volume_size       = var.root_volume_size
    }
  ]

  worker_groups_launch_template = [
    {
      name                                     = "preemptible0"
      override_instance_types                  = var.preemptible_instance_types
      subnets                                  = [sort(data.aws_subnet_ids.eks_workers.ids)[0]]
      asg_min_size                             = var.preemptible_asg_min_size
      asg_desired_capacity                     = var.preemptible_asg_desired_capacity
      asg_max_size                             = var.preemptible_asg_max_size
      asg_recreate_on_change                   = true
      bootstrap_extra_args                     = "--enable-docker-bridge 'true'"
      key_name                                 = var.key_name
      autoscaling_enabled                      = true
      protect_from_scale_in                    = var.protect_from_scale_in
      enabled_metrics                          = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
      pre_userdata                             = local.userdata
      kubelet_extra_args                       = "--node-labels=node.kubernetes.io/lifecycle=preemptible"
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = var.on_demand_percentage
      root_volume_size                         = var.root_volume_size
    },
    {
      name                                     = "preemptible1"
      override_instance_types                  = var.preemptible_instance_types
      subnets                                  = [sort(data.aws_subnet_ids.eks_workers.ids)[1]]
      asg_min_size                             = var.preemptible_asg_min_size
      asg_desired_capacity                     = var.preemptible_asg_desired_capacity
      asg_max_size                             = var.preemptible_asg_max_size
      asg_recreate_on_change                   = true
      bootstrap_extra_args                     = "--enable-docker-bridge 'true'"
      key_name                                 = var.key_name
      autoscaling_enabled                      = true
      protect_from_scale_in                    = var.protect_from_scale_in
      enabled_metrics                          = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
      pre_userdata                             = local.userdata
      kubelet_extra_args                       = "--node-labels=node.kubernetes.io/lifecycle=preemptible"
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = var.on_demand_percentage
      root_volume_size                         = var.root_volume_size
    },
    {
      name                                     = "preemptible2"
      override_instance_types                  = var.preemptible_instance_types
      subnets                                  = [sort(data.aws_subnet_ids.eks_workers.ids)[2]]
      asg_min_size                             = var.preemptible_asg_min_size
      asg_desired_capacity                     = var.preemptible_asg_desired_capacity
      asg_max_size                             = var.preemptible_asg_max_size
      asg_recreate_on_change                   = true
      bootstrap_extra_args                     = "--enable-docker-bridge 'true'"
      key_name                                 = var.key_name
      autoscaling_enabled                      = true
      protect_from_scale_in                    = var.protect_from_scale_in
      enabled_metrics                          = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
      pre_userdata                             = local.userdata
      kubelet_extra_args                       = "--node-labels=node.kubernetes.io/lifecycle=preemptible"
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = var.on_demand_percentage
      root_volume_size                         = var.root_volume_size
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
    Cluster   = var.cluster
  }
}
