locals {
  index_document = "index.html"
}

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "2.13.0"

  bucket = var.domain
  acl    = "private"

  tags = var.tags

  website = {
    index_document = local.index_document
  }

  block_public_acls       = false
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_acm_certificate" "certificate" {
  domain_name       = var.domain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

resource "aws_route53_record" "validate_records" {
  for_each = {
    for dvo in aws_acm_certificate.certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.route53_zone_id
}

resource "aws_acm_certificate_validation" "validation" {
  certificate_arn         = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.validate_records : record.fqdn]
}

resource "aws_cloudfront_origin_access_identity" "access_identity" {}

data "aws_iam_policy_document" "cloudfront_s3_access_policy" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    resources = [
      "${module.s3_bucket.s3_bucket_arn}/*"
    ]
    actions = [
      "s3:GetObject"
    ]
    principals {
      type = "AWS"
      identifiers = [
        aws_cloudfront_origin_access_identity.access_identity.iam_arn
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "s3_allow_from_cloudfront" {
  bucket = module.s3_bucket.s3_bucket_id
  policy = data.aws_iam_policy_document.cloudfront_s3_access_policy.json
}

resource "aws_cloudfront_distribution" "cloudfront" {
  enabled = true

  aliases             = [var.domain]
  default_root_object = local.index_document
  is_ipv6_enabled     = true

  origin {
    origin_id   = var.domain
    domain_name = module.s3_bucket.s3_bucket_bucket_regional_domain_name

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.access_identity.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.domain

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.certificate.arn
    ssl_support_method  = "sni-only"
  }

  tags = var.tags

  depends_on = [
    aws_acm_certificate_validation.validation
  ]
}

resource "aws_route53_record" "s3_alias" {
  zone_id = var.route53_zone_id
  name    = "${var.domain}."
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cloudfront.domain_name
    zone_id                = aws_cloudfront_distribution.cloudfront.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_iam_user" "deployer" {
  count = var.create_deployer_credentials ? 1 : 0

  name = "${var.domain}-website-deployer"

  tags = var.tags
}

data "aws_iam_policy_document" "deployer_policy" {
  count = var.create_deployer_credentials ? 1 : 0

  version = "2012-10-17"
  statement {
    effect = "Allow"
    resources = [
      "${module.s3_bucket.s3_bucket_arn}/*",
      module.s3_bucket.s3_bucket_arn
    ]
    actions = [
      "s3:GetObject",
      "s3:CopyObject",
      "s3:HeadObject",
      "s3:ListObjects",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutBucketWebsite",
      "s3:DeleteObject",
      "s3:DeleteObjects",
      "s3:ListBuckets",
      "s3:ListBucket",
      "s3:HeadBucket",
      "s3:GetBucketAcl",
    ]
  }
}

resource "aws_iam_user_policy" "deployer_policy" {
  count = var.create_deployer_credentials ? 1 : 0

  policy = data.aws_iam_policy_document.deployer_policy[0].json
  user   = aws_iam_user.deployer[0].name
}

resource "aws_iam_access_key" "deployer_credentials" {
  count = var.create_deployer_credentials ? 1 : 0

  user = aws_iam_user.deployer[0].name
}
