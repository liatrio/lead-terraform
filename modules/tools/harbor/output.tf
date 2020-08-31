output harbor_admin_password {
  value = random_string.harbor_admin_password.result
  sensitive   = true
}

output harbor_hostname {
  value = local.harbor_hostname
}