data "aws_caller_identity" "current" {
}

resource "aws_s3_bucket" "github-runner" {
  bucket = "github-runners-${data.aws_caller_identity.current.account_id}-${var.cluster}.liatr.io"
  tags = {
    Name        = "Github Runner States"
    ManagedBy   = "Terraform https://github.com/liatrio/lead-terraform"
    Cluster     = var.cluster
  }
}
