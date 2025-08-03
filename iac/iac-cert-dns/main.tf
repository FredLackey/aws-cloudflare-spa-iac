# Request ACM certificate
resource "aws_acm_certificate" "app_cert" {
  domain_name               = var.domain_names[0]
  subject_alternative_names = length(var.domain_names) > 1 ? slice(var.domain_names, 1, length(var.domain_names)) : []
  validation_method         = "DNS"

  tags = merge(var.tags, {
    Name        = "yourapp-cert-${var.environment}"
    Environment = var.environment
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Create DNS validation records in Cloudflare
resource "cloudflare_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.app_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = var.cloudflare_zone_id
  name    = each.value.name
  content = each.value.record
  type    = each.value.type
  ttl     = 60

  comment = "ACM validation for ${each.key} (${var.environment})"
}

# Wait for certificate validation
resource "aws_acm_certificate_validation" "app_cert" {
  certificate_arn         = aws_acm_certificate.app_cert.arn
  validation_record_fqdns = [for record in cloudflare_record.cert_validation : record.hostname]

  timeouts {
    create = "10m"
  }
}