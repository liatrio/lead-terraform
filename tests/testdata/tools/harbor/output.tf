output harbor_admin_password {
  value = module.harbor.harbor_admin_password
  sensitive   = true
}

output harbor_hostname {
  value = module.harbor.harbor_hostname
}