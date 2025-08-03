locals {
  # Generate outputs.json content
  outputs_json = {
    package_name = "iac-cert-dns"
    environment  = var.environment
    timestamp    = timestamp()
    resources_created = {
      certificates = [
        for domain in var.domain_names : {
          domain            = domain
          arn              = aws_acm_certificate_validation.app_cert.certificate_arn
          status           = "ISSUED"
          region           = "us-east-1"
          validation_method = "DNS"
        }
      ]
      dns_records = [
        for k, v in cloudflare_record.cert_validation : {
          name                  = v.name
          type                  = v.type
          cloudflare_record_id = v.id
          domain               = k
        }
      ]
    }
    terraform_outputs = {
      certificate_arn = aws_acm_certificate_validation.app_cert.certificate_arn
    }
  }
}

# Generate outputs.json file
resource "local_file" "outputs_json" {
  content  = jsonencode(local.outputs_json)
  filename = "${path.module}/outputs.json"

  depends_on = [aws_acm_certificate_validation.app_cert]
}