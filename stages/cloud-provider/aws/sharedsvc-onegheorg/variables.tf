variable "region" {
  default = "us-east-1"
}
variable "onegheorg_pipeline_roles" {
  type = list(string)
  default = []
}

variable "github_runners_namespace" {
  default = "github-runners-liatrio"
}
