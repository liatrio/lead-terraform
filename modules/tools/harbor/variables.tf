variable enable {
  default = true
}

variable namespace {}

variable cluster {}

variable root_zone_name {}

variable harbor_registry_disk_size {
  default = "200Gi"
}

variable harbor_chartmuseum_disk_size {
  default = "100Gi"
}

variable k8s_storage_class {}

variable issuer_name {}

variable issuer_kind {}

variable protect_pvc_resources {
  default = true
}

variable admin_password {}
