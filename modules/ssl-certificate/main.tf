data "aws_region" "current" {}

check "domain_zone_name_validation" {
  assert {
    condition     = !(var.domain_zone_name == null && var.create_dns_records)
    error_message = "If create_dns_records is true domain_zone_name can't be set null. Please set domain_zone_name!"
  }
}

provider "aws" {
  alias  = "region"
  region = var.is_virginia_region ? "us-east-1" : data.aws_region.current.name
}

resource "aws_acm_certificate" "cerificate" {
  provider          = aws.region
  domain_name       = var.domain_name
  validation_method = "DNS"
}

resource "aws_acm_certificate_validation" "cerificate_validation" {
  provider                = aws.region
  certificate_arn         = aws_acm_certificate.cerificate.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation_record : record.fqdn]
}

data "aws_route53_zone" "public_zone" {
  count        = var.create_dns_records ? 1 : 0
  name         = var.domain_zone_name
  private_zone = false
}

resource "aws_route53_record" "cert_validation_record" {
  provider = aws.region
  for_each = {
    for dvo in var.create_dns_records ? aws_acm_certificate.cerificate.domain_validation_options : [] : dvo.domain_name => {
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
  zone_id         = data.aws_route53_zone.public_zone[0].zone_id
}
