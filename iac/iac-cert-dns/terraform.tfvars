# PLACEHOLDER VALUES - Replace with your actual configuration
environment          = "sbx"
cloudflare_api_token = "your-cloudflare-api-token"  # Get from Cloudflare dashboard
cloudflare_zone_id   = "your-cloudflare-zone-id"    # Find in Cloudflare zone overview

# Domain names to secure with ACM certificate
domain_names = ["app-sbx.yourdomain.com"]  # Replace yourdomain.com with your domain

# Additional tags
tags = {
  Product     = "yourapp"  # Replace with your application name
  Environment = "sbx"
  ManagedBy   = "terraform"
  Owner       = "cloud-owner"
  Purpose     = "acm-certificate"
}