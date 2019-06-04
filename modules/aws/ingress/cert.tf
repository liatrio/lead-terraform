resource "aws_acm_certificate" "cert" {
  domain_name       = "*.${aws_route53_zone.ns_zone.name}"
  validation_method = "DNS"
  tags              = "${merge(local.tags, map("Name","${var.cluster}-${var.namespace}-ingress"))}"
}

  
resource "aws_route53_record" "cert_validation" {
  zone_id = "${aws_route53_zone.ns_zone.zone_id}"
  name    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_type}"
  records = ["${aws_acm_certificate.cert.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}


resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = "${aws_acm_certificate.cert.arn}"
  validation_record_fqdns = ["${aws_route53_record.cert_validation.fqdn}"]
}