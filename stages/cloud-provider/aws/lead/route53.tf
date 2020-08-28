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
  ttl     = "30"

  records = [
    aws_route53_zone.cluster_zone.name_servers[0],
    aws_route53_zone.cluster_zone.name_servers[1],
    aws_route53_zone.cluster_zone.name_servers[2],
    aws_route53_zone.cluster_zone.name_servers[3],
  ]
}
