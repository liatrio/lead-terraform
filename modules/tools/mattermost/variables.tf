variable "namespace" {}
variable "mattermost_hostname" {}
variable "sparky_version" {}
variable "toolchain_image_repo" {}
variable "mattermost_vault_path" {}
variable "bot_email" {
  default = "sparky@liatr.io"
}
variable "bot_username" {
  default = "sparky"
}
