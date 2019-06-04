# resource "kubernetes_secret" "artifactory" {
#   metadata {
#     name      = "jenkins-credential-artifactory"
#     namespace = "${var.namespace}"

#     labels {
#       "app.kubernetes.io/name"       = "jenkins"
#       "app.kubernetes.io/instance"   = "jenkins"
#       "app.kubernetes.io/component"  = "jenkins-master"
#       "app.kubernetes.io/managed-by" = "Terraform"
#       "jenkins.io/credentials-type"  = "usernamePassword"
#     }

#     annotations {
#       "source-repo"                        = "https://github.com/liatrio/lead-toolchain"
#       "jenkins.io/credentials-description" = "Artifactory Credentials"
#     }
#   }

#   type = "Opaque"

#   data {
#     username = "${var.artifactory_username}"
#     password = "${var.artifactory_password}"
#   }
# }

# resource "kubernetes_secret" "slack" {
#   metadata {
#     name      = "jenkins-credential-slack"
#     namespace = "${var.namespace}"

#     labels {
#       "app.kubernetes.io/name"       = "jenkins"
#       "app.kubernetes.io/instance"   = "jenkins"
#       "app.kubernetes.io/component"  = "jenkins-master"
#       "app.kubernetes.io/managed-by" = "Terraform"
#       "jenkins.io/credentials-type"  = "secretText"
#     }

#     annotations {
#       "source-repo"                        = "https://github.com/liatrio/lead-toolchain"
#       "jenkins.io/credentials-description" = "Slack Token"
#     }
#   }

#   type = "Opaque"

#   data {
#     text = "${var.slack_token}"
#   }
# }

# resource "kubernetes_secret" "github" {
#   metadata {
#     name      = "jenkins-credential-github"
#     namespace = "${var.namespace}"

#     labels {
#       "app.kubernetes.io/name"       = "jenkins"
#       "app.kubernetes.io/instance"   = "jenkins"
#       "app.kubernetes.io/component"  = "jenkins-master"
#       "app.kubernetes.io/managed-by" = "Terraform"
#       "jenkins.io/credentials-type"  = "usernamePassword"
#     }

#     annotations {
#       "source-repo"                        = "https://github.com/liatrio/lead-toolchain"
#       "jenkins.io/credentials-description" = "GitHub Credentials"
#     }
#   }

#   type = "Opaque"

#   data {
#     username = "${var.github_username}"
#     password = "${var.github_password}"
#   }
# }

# resource "kubernetes_secret" "sonarqube" {
#   metadata {
#     name      = "jenkins-credential-sonarqube"
#     namespace = "${var.namespace}"

#     labels {
#       "app.kubernetes.io/name"       = "jenkins"
#       "app.kubernetes.io/instance"   = "jenkins"
#       "app.kubernetes.io/component"  = "jenkins-master"
#       "app.kubernetes.io/managed-by" = "Terraform"
#       "jenkins.io/credentials-type"  = "secretText"
#     }

#     annotations {
#       "source-repo"                        = "https://github.com/liatrio/lead-toolchain"
#       "jenkins.io/credentials-description" = "Sonarqube Token"
#     }
#   }

#   type = "Opaque"

#   data {
#     text = "${var.sonarqube_token}"
#   }
# }
