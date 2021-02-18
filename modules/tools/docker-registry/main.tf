resource "helm_release" "docker_registry" {
  chart      = "docker-registry"
  name       = "docker-registry"
  repository = "https://helm.twun.io"
  version    = "1.10.1"
  namespace  = var.namespace

  values = [
    templatefile("${path.module}/values.yaml.tpl", {
      aws_access_key_id = var.docker_registry_aws_access_key_id
      s3_bucket_name    = var.docker_registry_s3_bucket_name
      region            = var.region
      hostname          = var.hostname
    })
  ]

  set_sensitive {
    name  = "secrets.s3.secretKey"
    value = var.docker_registry_aws_secret_access_key
  }
}
