variable namespace {
  type = string
}

variable release_name {
  type = string
  description = "Name of the release for the RunnerDeployments"
}

variable runner_labels {
  type = list(string)
  default = []
  description = "List of Github labels to apply to the runners"
}

variable github_org {
  type = string
  description = "Github organization to register the runners to"
}