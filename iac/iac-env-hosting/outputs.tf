output "cloudfront_domain_name" {
  description = "Public CloudFront domain for the front-end"
  value       = aws_cloudfront_distribution.app.domain_name
}

output "lambda_function_url" {
  description = "Direct URL endpoint for the backend Lambda"
  value       = aws_lambda_function_url.api.function_url
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket hosting the frontend"
  value       = aws_s3_bucket.frontend.bucket
}

output "lambda_function_name" {
  description = "Name of the deployed Lambda function"
  value       = aws_lambda_function.api.function_name
}

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.app.id
}

output "custom_domain_name" {
  description = "Custom domain name pointing to CloudFront"
  value       = cloudflare_record.app_dns.hostname
}

output "dns_record_id" {
  description = "Cloudflare DNS record ID"
  value       = cloudflare_record.app_dns.id
}