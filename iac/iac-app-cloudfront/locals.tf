locals {
  # Generate outputs.json content
  outputs_json = {
    package_name = "iac-app-cloudfront"
    environment  = var.environment
    timestamp    = timestamp()
    resources_updated = {
      s3_buckets = [
        {
          name         = data.aws_s3_bucket.existing.bucket
          files_updated = true
          last_sync    = timestamp()
          files_count  = length(aws_s3_object.website_files)
        }
      ]
      cloudfront_distributions = [
        {
          id               = data.aws_cloudfront_distribution.existing.id
          cache_invalidated = true
          last_invalidation = timestamp()
        }
      ]
    }
    terraform_outputs = {
      bucket_name     = data.aws_s3_bucket.existing.bucket
      distribution_id = data.aws_cloudfront_distribution.existing.id
      files_uploaded  = length(aws_s3_object.website_files)
    }
  }
}

# Generate outputs.json file
resource "local_file" "outputs_json" {
  content  = jsonencode(local.outputs_json)
  filename = "${path.module}/outputs.json"

  depends_on = [
    aws_s3_object.website_files,
    null_resource.invalidate_cache
  ]
}