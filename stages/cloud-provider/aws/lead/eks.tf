module "eks" {
  source                           = "../../../../modules/environment/aws/eks"

  region                           = var.region
  cluster                          = var.cluster_name
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
  codebuild_role                   = var.enable_aws_code_services ? module.codeservices.codebuild_role : ""
  vpc_name                         = var.vpc_name

  // TODO: remove the following policy from the worker node role once terraform is bumped
  //       to version that includes fix for: https://github.com/hashicorp/terraform/issues/22992
  workers_additional_policies = [aws_iam_policy.operator_jenkins.arn]
}
