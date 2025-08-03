output "certificate_arn" {
  description = "ARN of the validated ACM certificate"
  value       = aws_acm_certificate_validation.app_cert.certificate_arn
}

output "certificate_domain_validation_options" {
  description = "Domain validation options used for the certificate"
  value       = aws_acm_certificate.app_cert.domain_validation_options
}

output "certificate_status" {
  description = "Status of the certificate"
  value       = aws_acm_certificate_validation.app_cert.certificate_arn != null ? "ISSUED" : "PENDING"
}

output "domain_names" {
  description = "Domain names covered by the certificate"
  value       = var.domain_names
}

output "cloudflare_validation_records" {
  description = "Cloudflare DNS records created for certificate validation"
  value = {
    for k, v in cloudflare_record.cert_validation : k => {
      id       = v.id
      name     = v.name
      content  = v.content
      type     = v.type
      hostname = v.hostname
    }
  }
}