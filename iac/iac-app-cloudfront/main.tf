# Data sources to reference existing infrastructure created by DevOps
# These are READ-ONLY - we never modify the infrastructure itself
data "aws_s3_bucket" "existing" {
  bucket = var.bucket_name
}

data "aws_cloudfront_distribution" "existing" {
  id = var.distribution_id
}

# Upload files to existing S3 bucket
resource "aws_s3_object" "website_files" {
  for_each = fileset(var.source_dir, "**/*")
  
  bucket = data.aws_s3_bucket.existing.bucket
  key    = each.value
  source = "${var.source_dir}/${each.value}"
  
  # Set content type based on file extension
  content_type = lookup({
    "html" = "text/html"
    "css"  = "text/css"
    "js"   = "application/javascript"
    "json" = "application/json"
    "png"  = "image/png"
    "jpg"  = "image/jpeg"
    "jpeg" = "image/jpeg"
    "gif"  = "image/gif"
    "svg"  = "image/svg+xml"
    "ico"  = "image/x-icon"
    "woff" = "font/woff"
    "woff2" = "font/woff2"
    "ttf"  = "font/ttf"
    "eot"  = "application/vnd.ms-fontobject"
  }, split(".", each.value)[length(split(".", each.value)) - 1], "application/octet-stream")
  
  # Generate ETag for cache busting
  etag = filemd5("${var.source_dir}/${each.value}")
}

# Invalidate CloudFront cache when files change
resource "null_resource" "invalidate_cache" {
  triggers = {
    # Trigger invalidation when any file changes
    file_hashes = join(",", [for f in aws_s3_object.website_files : f.etag])
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Invalidating CloudFront cache for distribution: ${var.distribution_id}"
      aws cloudfront create-invalidation \
        --distribution-id ${var.distribution_id} \
        --paths "/*" \
        --profile your-aws-profile-name
      
      echo "Cache invalidation initiated. It may take 10-15 minutes to complete."
    EOT
  }

  depends_on = [aws_s3_object.website_files]
}