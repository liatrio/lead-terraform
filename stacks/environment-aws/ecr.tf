module "springtrader_builder_ecr_repo" {
  source = "../../modules/common/public-ecr-repository"

  enabled = var.create_public_ecr_repos
  name    = "springtrader-builder"
}

module "springtrader_runner_ecr_repo" {
  source = "../../modules/common/public-ecr-repository"

  enabled = var.create_public_ecr_repos
  name    = "springtrader-runner"
}
