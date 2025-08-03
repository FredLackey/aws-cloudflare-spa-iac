output "bucket_name" {
  description = "S3 bucket name (from existing bucket)"
  value       = data.aws_s3_bucket.existing.bucket
}

output "distribution_id" {
  description = "CloudFront distribution ID (from existing distribution)"
  value       = data.aws_cloudfront_distribution.existing.id
}

output "distribution_domain_name" {
  description = "CloudFront distribution domain name (from existing distribution)"
  value       = data.aws_cloudfront_distribution.existing.domain_name
}

output "content_update_trigger" {
  description = "Timestamp that triggers content updates"
  value       = null_resource.invalidate_cache.id
}

output "files_uploaded" {
  description = "Number of files uploaded to S3"
  value       = length(aws_s3_object.website_files)
}