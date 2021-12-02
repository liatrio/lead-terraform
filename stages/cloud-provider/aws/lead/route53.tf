data "aws_route53_zone" "root_zone" {
  name = var.root_zone_name
}

resource "aws_route53_zone" "cluster_zone" {
  name = "${var.cluster_name}.${data.aws_route53_zone.root_zone.name}"
  tags = local.tags
}

resource "aws_route53_record" "cluster_zone" {
  zone_id = data.aws_route53_zone.root_zone.zone_id
  name    = "${var.cluster_name}.${data.aws_route53_zone.root_zone.name}"
  type    = "NS"
  ttl     = "60"

  records = aws_route53_zone.cluster_zone.name_servers
}

// zone for vcluster records

resource "aws_route53_zone" "vcluster" {
  count = var.enable_vcluster ? 1 : 0
  name  = "vcluster.${aws_route53_zone.cluster_zone.name}"
}

resource "aws_route53_record" "vcluster_ns" {
  count   = var.enable_vcluster ? 1 : 0
  zone_id = aws_route53_zone.cluster_zone.zone_id
  name    = aws_route53_zone.vcluster[0].name
  type    = "NS"
  ttl     = "60"

  records = aws_route53_zone.vcluster[0].name_servers
}

resource "aws_route53_record" "vcluster_soa" {
  count   = var.enable_vcluster ? 1 : 0
  zone_id = aws_route53_zone.vcluster[0].zone_id
  name    = aws_route53_zone.vcluster[0].name
  type    = "SOA"
  ttl     = "60"

  allow_overwrite = true

  records = [
    "${aws_route53_zone.vcluster[0].name_servers[0]}. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400"
  ]
}
