variable "bucket_name" {
  description = "Name of existing S3 bucket (provided by DevOps team)"
  type        = string
  # Example: "yourapp-frontend-sbx"
}

variable "distribution_id" {
  description = "ID of existing CloudFront distribution (provided by DevOps team)"
  type        = string
  # Example: "E1234567890ABC"
}

variable "source_dir" {
  description = "Path to the local directory containing built SPA assets"
  type        = string
  # Example: "../../apps/your-actual-app/dist"
}

variable "environment" {
  description = "Environment name (e.g., sbx, dev, prod)"
  type        = string
  default     = "sbx"
}