include {
  path = "${find_in_parent_folders()}"
}

inputs = {
  # Cluster info
  cluster_name        = "docker-for-desktop"
  aws_environment     = "docker-for-desktop"
  root_zone_name      = "localhost"

  # Toolchain config
  enable_cluster_autoscaler                   = false
  enable_kube_downscaler                      = false
  enable_k8s_spot_termination_handler         = false
  enable_istio                                = false

  cert_issuer_type = "selfSigned"

  enable_keycloak          = false
  enable_harbor            = false
  enable_rode              = false
  enable_vault             = false
  enable_elasticstack      = false
  enable_sdm               = false
  enable_test_user         = false
  enable_aws_code_services = false

  prometheus_slack_channel = "#sandbox-toolchain-monitoring"
  toolchain_image_repo     = "489130170427.dkr.ecr.us-east-1.amazonaws.com"

  product_types      = ["product-jenkins"]
  lead_sdm_operators = ["toolchain", "elasticsearch", "slack", "product"]

  # Tooclahin image versions
  product_version        = "6e9c43f"
  sdm_version            = "v2.0.6-53-g5592d5d"
  dashboard_version      = "v2.0.1-11-g444016b"
  builder_images_version = "v2.0.2-28-g0fadddc"
  jenkins_image_version  = "v2.0.2-28-g0fadddc"
  lab_partner_version    = "v0.0.1-6-g78a1203"

  vault_address               = "https://vault.internal.services.liatr.io"
  iam_caller_identity_headers = run_cmd("--terragrunt-quiet", "../../scripts/aws-get-signed-caller-identity-headers/run.sh")
}

terraform {
  source = "../../..//stages/apps/lead"
}
