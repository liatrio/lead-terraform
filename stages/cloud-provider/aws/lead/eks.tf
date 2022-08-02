module "eks" {
  source = "../../../../modules/environment/aws/eks"

  region                           = var.region
  cluster                          = var.cluster_name
  cluster_version                  = var.cluster_version
  cluster_addons                   = var.cluster_addons
  s3-logging-id                    = var.s3-logging-id
  key_name                         = var.key_name
  preemptible_instance_types       = var.instance_types
  preemptible_asg_min_size         = var.asg_min_size
  preemptible_asg_max_size         = var.asg_max_size
  preemptible_asg_desired_capacity = var.asg_desired_capacity
  essential_instance_type          = var.essential_instance_type
  essential_asg_max_size           = var.essential_asg_max_size
  essential_asg_min_size           = var.essential_asg_min_size
  essential_asg_desired_capacity   = var.essential_asg_desired_capacity
  essential_taint_key              = var.essential_taint_key
  on_demand_percentage             = var.on_demand_percentage
  enable_aws_code_services         = var.enable_aws_code_services
  codebuild_role                   = var.enable_aws_code_services ? module.codeservices[0].codebuild_role : ""
  vpc_name                         = var.vpc_name
  docker_registry_mirror           = var.docker_registry_mirror
  enable_ssh_access                = var.enable_eks_ssh_access
  additional_mapped_roles          = var.additional_mapped_roles
}
