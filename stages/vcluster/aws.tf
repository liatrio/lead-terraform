// we want the CA certificate sha1 fingerprint. it should be the first item in the cert list
data "tls_certificate" "vcluster_api_server_cert" {
  url          = "https://${var.vcluster_apiserver_host}"
  verify_chain = false

  depends_on = [
    null_resource.wait_for_vcluster_api
  ]
}

resource "aws_iam_openid_connect_provider" "vcluster_openid_provider" {
  client_id_list = [
    var.vcluster_apiserver_host
  ]
  thumbprint_list = [
    data.tls_certificate.vcluster_api_server_cert.certificates[0].sha1_fingerprint
  ]
  url = "https://${var.vcluster_apiserver_host}"
}
