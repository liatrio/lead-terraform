resource "aws_ses_domain_identity" "cluster_domain" {
  domain = "${var.cluster}.${var.root_zone_name}"
}

resource "aws_route53_record" "ses_verification" {
  zone_id = aws_route53_zone.cluster_zone.zone_id
  name    = "_amazonses.${aws_ses_domain_identity.cluster_domain.domain}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.cluster_domain.verification_token]
}

resource "aws_ses_domain_identity_verification" "cluster_domain" {
  domain     = aws_ses_domain_identity.cluster_domain.domain
  depends_on = [aws_route53_record.ses_verification]
}

module "ses_smtp" {
  source       = "../../modules/common/aws-ses-smtp"
  name         = "ses-smtp-${var.toolchain_namespace}"
  from_address = "noreply@${aws_ses_domain_identity.cluster_domain.domain}"
}
