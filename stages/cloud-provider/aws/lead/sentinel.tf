module "azure_sentinel" {
  source = "../../../../modules/environment/aws/azure-sentinel"

  count = var.enable_azure_sentinel ? 1 : 0

  azure_sentinel_aws_account_id = var.azure_sentinel_aws_account_id
  azure_sentinel_external_id    = var.azure_sentinel_external_id
  cluster                       = var.cluster_name
}
