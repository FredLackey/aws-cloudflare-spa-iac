locals {
  # Generate outputs.json content
  outputs_json = {
    package_name = "iac-env-hosting"
    environment  = var.environment
    timestamp    = timestamp()
    resources_created = {
      s3_buckets = [
        {
          name     = aws_s3_bucket.frontend.bucket
          purpose  = "frontend-hosting"
          region   = "us-east-1"
        }
      ]
      lambda_functions = [
        {
          name         = aws_lambda_function.api.function_name
          function_url = aws_lambda_function_url.api.function_url
          runtime      = aws_lambda_function.api.runtime
        }
      ]
      cloudfront_distributions = [
        {
          id            = aws_cloudfront_distribution.app.id
          domain_name   = aws_cloudfront_distribution.app.domain_name
          custom_domain = "app-${var.environment}.yourdomain.com"
        }
      ]
      dns_records = [
        {
          id       = cloudflare_record.app_dns.id
          name     = cloudflare_record.app_dns.hostname
          type     = cloudflare_record.app_dns.type
          content  = cloudflare_record.app_dns.content
          purpose  = "cloudfront-alias"
        }
      ]
    }
    terraform_outputs = {
      cloudfront_domain_name = aws_cloudfront_distribution.app.domain_name
      lambda_function_url    = aws_lambda_function_url.api.function_url
      s3_bucket_name         = aws_s3_bucket.frontend.bucket
      lambda_function_name   = aws_lambda_function.api.function_name
    }
  }
}

# Generate outputs.json file
resource "local_file" "outputs_json" {
  content  = jsonencode(local.outputs_json)
  filename = "${path.module}/outputs.json"

  depends_on = [
    aws_s3_bucket.frontend,
    aws_lambda_function.api,
    aws_lambda_function_url.api,
    aws_cloudfront_distribution.app,
    cloudflare_record.app_dns
  ]
}