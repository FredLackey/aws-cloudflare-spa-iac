variable "certificate_arn" {
  description = "ARN of the ACM certificate from iac-cert-dns package"
  type        = string
  # Example: "arn:aws:acm:us-east-1:123456789012:certificate/abc123-def456-ghi789"
}

variable "react_build_path" {
  description = "Local path to compiled React app to upload to S3"
  type        = string
  default     = "../../apps/placeholder-app/dist"
}

variable "lambda_zip_path" {
  description = "Local path to zipped Express.js Lambda deployment package"
  type        = string
  default     = "../../apps/placeholder-api/lambda-deployment.zip"
}

variable "environment" {
  description = "Environment name (e.g., sbx, dev, prod)"
  type        = string
  default     = "sbx"
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 7
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token for DNS updates"
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID for yourdomain.com"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "yourapp"
    Environment = "sbx"
    ManagedBy   = "terraform"
  }
}