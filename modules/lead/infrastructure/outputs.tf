output "namespace" {
  value = module.system_namespace.name
}

output "crd_waiter" {
  value = module.cert_manager.crd_waiter
}

