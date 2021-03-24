# Create a new repository
resource "artifactory_local_repository" "docker_repository" {
  key             = "docker-general"
  package_type    = "docker"
  repo_layout_ref = "simple-default"
  description     = "A repository for docker images"
}

resource "artifactory_local_repository" "helm_repository" {
  key             = "helm-general"
  package_type    = "helm"
  repo_layout_ref = "simple-default"
  description     = "A repository for helm charts"
}