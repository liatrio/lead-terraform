terragrunt = {
  include {
    path = "${find_in_parent_folders()}"
  }
}

root_zone_name = "localhost"
cluster = "minikube"
