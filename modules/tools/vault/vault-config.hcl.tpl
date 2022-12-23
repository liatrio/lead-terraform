ui = true

listener "tcp" {
  address                  = "0.0.0.0:8200"
  tls_cert_file            = "/tls/vault-tls-certificate/tls.crt"
  tls_key_file             = "/tls/vault-tls-certificate/tls.key"
  tls_disable_client_certs = true
}

storage "dynamodb" {
  region     = "${region}"
  ha_enabled = "true"
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


