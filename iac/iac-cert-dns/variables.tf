variable "environment" {
  description = "Environment name (e.g., sbx, dev, prod)"
  type        = string
  default     = "sbx"
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID for yourdomain.com"
  type        = string
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token for DNS updates"
  type        = string
  sensitive   = true
}

variable "domain_names" {
  description = "List of domain names to secure (e.g. ['app-sbx.yourdomain.com'])"
  type        = list(string)
  default     = ["app-sbx.yourdomain.com"]
}

variable "tags" {
  description = "Tags to apply to ACM resources"
  type        = map(string)
  default = {
    Product     = "yourapp"
    Environment = "sbx"
    ManagedBy   = "terraform"
    Owner       = "cloud-owner"
  }
}