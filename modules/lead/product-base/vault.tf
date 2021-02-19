data "vault_auth_backend" "kubernetes" {
  path = "kubernetes"
}

// vault configuration for connecting to database
resource "vault_database_secret_backend_connection" "mongodb" {
  backend = "mongodb"
  name    = "${var.product_name}-mongodb"

  allowed_roles = [
    local.vault_mongodb_staging_role
  ]

  data = {
    username = "root"
    password = random_password.mongodb_root_password.result
  }

  mongodb {
    connection_url = "mongodb://{{username}}:{{password}}@mongodb.${var.product_name}-db.svc.cluster.local/admin"
  }

  verify_connection = false
}

// vault policy for getting credentials for database
resource "vault_policy" "mongodb_credentials_policy" {
  name   = "${var.product_name}-mongodb"
  policy = <<EOF
path "mongodb/creds/{{identity.entity.aliases.${data.vault_auth_backend.kubernetes.accessor}.metadata.service_account_namespace}}" {
  capabilities = ["read"]
}
EOF
}
