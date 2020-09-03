include {
  path = "${find_in_parent_folders()}"
}

dependency "apps" {
  config_path = "../apps"
}

inputs = {
  region              = dependency.apps.outputs.region
  cluster_name        = "docker-for-desktop"

  enable_keycloak     = false
  enable_harbor       = false
  enable_test_user    = false
  enable_google_login = false

  keycloak_hostname   = dependency.apps.outputs.keycloak_hostname
  harbor_hostname     = dependency.apps.outputs.harbor_hostname
  kibana_hostname     = dependency.apps.outputs.kibana_hostname

  toolchain_namespace = dependency.apps.outputs.toolchain_namespace

  vault_address               = "https://vault.internal.services.liatr.io"
  iam_caller_identity_headers = run_cmd("--terragrunt-quiet", "../../scripts/aws-get-signed-caller-identity-headers/run.sh")
}

terraform {
  source = "github.com/liatrio/lead-terraform//stages/config/lead"
}
