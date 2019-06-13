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
