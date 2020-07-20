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

  access_key = "${aws_access_key_id}"
  secret_key = "${aws_secret_access_key}"
}

seal "awskms" {
  region     = "${region}"
  access_key = "${aws_access_key_id}"
  secret_key = "${aws_secret_access_key}"

  kms_key_id = "${kms_key_id}"
}
