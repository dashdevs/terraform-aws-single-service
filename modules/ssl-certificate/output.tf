output "ssl_certificate_arn" {
  value = aws_acm_certificate.cerificate.arn
}

output "ssl_certificate_validation_dns_records" {
  value = [
    for dvo in aws_acm_certificate.cerificate.domain_validation_options : "${dvo.resource_record_name} ${dvo.resource_record_type} ${dvo.resource_record_value}"
  ]
}
