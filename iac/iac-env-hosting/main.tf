# S3 bucket for frontend hosting
resource "aws_s3_bucket" "frontend" {
  bucket = "yourapp-frontend-${var.environment}"

  tags = merge(var.tags, {
    Name        = "yourapp-frontend-${var.environment}"
    Environment = var.environment
    Purpose     = "frontend-hosting"
  })
}

# S3 bucket versioning
resource "aws_s3_bucket_versioning" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 bucket public access block
resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CloudFront Origin Access Control
resource "aws_cloudfront_origin_access_control" "frontend" {
      name                              = "yourapp-frontend-${var.environment}-oac"
    description                       = "OAC for yourapp frontend S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# S3 bucket policy for CloudFront
resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  policy = jsonencode({
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.frontend.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.app.arn
          }
        }
      }
    ]
  })

  depends_on = [aws_cloudfront_distribution.app]
}

# IAM role for Lambda execution
resource "aws_iam_role" "lambda_execution" {
  name = "yourapp-lambda-execution-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name        = "yourapp-lambda-execution-${var.environment}"
    Environment = var.environment
    Purpose     = "lambda-execution"
  })
}

# Attach basic execution role policy to Lambda role
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda function
resource "aws_lambda_function" "api" {
  filename         = var.lambda_zip_path
  function_name    = "yourapp-api-${var.environment}"
  role            = aws_iam_role.lambda_execution.arn
  handler         = "index.handler"
  runtime         = "nodejs20.x"
  timeout         = 30
  memory_size     = 128

  source_code_hash = filebase64sha256(var.lambda_zip_path)

  environment {
    variables = {
      NODE_ENV        = var.environment
      CORS_ORIGINS    = "https://app-${var.environment}.yourdomain.com"
    }
  }

  tags = merge(var.tags, {
    Name        = "yourapp-api-${var.environment}"
    Environment = var.environment
    Purpose     = "api-backend"
  })
}

# CloudWatch log group for Lambda function
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.api.function_name}"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, {
    Name        = "yourapp-lambda-logs-${var.environment}"
    Environment = var.environment
    Purpose     = "lambda-logging"
  })
}

# Lambda function URL
resource "aws_lambda_function_url" "api" {
  function_name      = aws_lambda_function.api.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = false
    allow_origins     = ["*"]
    allow_methods     = ["*"]
    allow_headers     = ["date", "keep-alive"]
    expose_headers    = ["date", "keep-alive"]
    max_age          = 86400
  }
}

# CloudFront distribution
resource "aws_cloudfront_distribution" "app" {
  origin {
    domain_name              = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.frontend.id
    origin_id                = "S3-${aws_s3_bucket.frontend.bucket}"
  }

  origin {
    domain_name = replace(replace(aws_lambda_function_url.api.function_url, "https://", ""), "/", "")
    origin_id   = "Lambda-${aws_lambda_function.api.function_name}"

    custom_origin_config {
      http_port              = 443
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = ["app-${var.environment}.yourdomain.com"]

  # Default behavior (serve from S3)
  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${aws_s3_bucket.frontend.bucket}"
    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  # API behavior (forward to Lambda)
  ordered_cache_behavior {
    path_pattern           = "/api/*"
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = "Lambda-${aws_lambda_function.api.function_name}"
    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = true
      headers      = ["Accept", "Authorization", "Content-Type", "Origin", "Referer"]
      cookies {
        forward = "all"
      }
    }

    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0
  }

  # Custom error response for SPA routing
  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = merge(var.tags, {
    Name        = "yourapp-app-${var.environment}"
    Environment = var.environment
    Purpose     = "app-distribution"
  })
}

# Upload React build files to S3
resource "aws_s3_object" "frontend_files" {
  for_each = fileset(var.react_build_path, "**/*")
  
  bucket       = aws_s3_bucket.frontend.bucket
  key          = each.value
  source       = "${var.react_build_path}/${each.value}"
  content_type = lookup(
    {
      "html" = "text/html",
      "css"  = "text/css",
      "js"   = "application/javascript",
      "json" = "application/json",
      "png"  = "image/png",
      "jpg"  = "image/jpeg",
      "jpeg" = "image/jpeg",
      "gif"  = "image/gif",
      "svg"  = "image/svg+xml",
      "ico"  = "image/x-icon",
      "woff" = "font/woff",
      "woff2" = "font/woff2"
    },
    split(".", each.value)[length(split(".", each.value)) - 1],
    "application/octet-stream"
  )
  etag = filemd5("${var.react_build_path}/${each.value}")

  tags = merge(var.tags, {
    Environment = var.environment
    Purpose     = "frontend-asset"
  })
}

# Create DNS CNAME record pointing to CloudFront distribution
resource "cloudflare_record" "app_dns" {
  zone_id = var.cloudflare_zone_id
  name    = "app-${var.environment}"
  content = aws_cloudfront_distribution.app.domain_name
  type    = "CNAME"
  ttl     = 300

  comment = "Points to CloudFront distribution for ${var.environment} environment"

  depends_on = [aws_cloudfront_distribution.app]
}