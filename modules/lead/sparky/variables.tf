variable "namespace" {
  type = string
}

variable "sparky_version" {
  type = string
}

variable "image_pull_secret_name" {
  type = string
}

variable "slack_app_token" {
  type      = string
  sensitive = true
}

variable "slack_oauth_access_token" {
  type      = string
  sensitive = true
}
