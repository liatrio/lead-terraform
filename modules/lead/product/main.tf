locals {
  protocol = var.cluster_domain == "docker-for-desktop.localhost" ? "http" : "https"
}

provider "kubernetes" {
  alias = "toolchain"
}

provider "helm" {
  alias = "toolchain"
}

provider "kubernetes" {
  alias = "staging"
}

provider "helm" {
  alias = "staging"
}

provider "kubernetes" {
  alias = "production"
}

provider "helm" {
  alias = "production"
}

provider "kubernetes" {
  alias = "system"
}

provider "helm" {
  alias = "system"
}
