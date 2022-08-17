module "velero-schedules" {
  count = var.enable_velero_schedules ? 1 : 0
  source = "../../../modules/tools/velero-schedules"
  velero_status = try(module.velero[0].velero_status, true)
  schedules = [
    {
      name = try(module.harbor[0].release_name, "")
      interval = "0 1 * * *"
      namespaces = ["toolchain"]
      labels = {
        app     = "harbor"
        release = "harbor"
      }
    },
  ]
  depends_on = [
    module.velero
  ]
}