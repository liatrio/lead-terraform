remote_state {
  backend = "s3"
  config = {
    bucket         = "lead-sdm-operators-${get_aws_account_id()}-${get_env("CLUSTER", "lead")}.liatr.io"
    key            = "product-${get_env("PRODUCT_NAME", "UNDEFINED_PRODUCT")}-terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "lead-sdm-operators-${get_env("CLUSTER", "lead")}"
    s3_bucket_tags = {
      owner = "terragrunt"
      name  = "Terraform state storage"
    }
    dynamodb_table_tags = {
      owner = "terragrunt"
      name  = "Terraform lock table"
    }
  }
}
