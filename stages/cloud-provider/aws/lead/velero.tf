module "velero" {
  source = "../../../../modules/environment/aws/velero"

  velero_user                                  = var.velero_user
}