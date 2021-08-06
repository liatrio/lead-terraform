ui = true

listener "tcp" {
  tls_disable     = 1
  address         = "[::]:8200"
  cluster_address = "[::]:8201"
}

storage "dynamodb" {
  region     = "${region}"
  ha_enabled = "false"
  table      = "${dynamodb_table_name}"

  max_parallel = "20"
}

seal "awskms" {
  region     = "${region}"
  kms_key_id = "${kms_key_id}"
}
