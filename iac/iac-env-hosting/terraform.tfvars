# PLACEHOLDER VALUES - Replace with your actual configuration
# Environment configuration
environment = "sbx"

# Certificate ARN from iac-cert-dns package
# Get this value after running iac-cert-dns: terraform output certificate_arn
certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/your-certificate-id"

# CloudWatch log retention (7 days for sandbox)
log_retention_days = 7

# Cloudflare DNS configuration
cloudflare_api_token = "your-cloudflare-api-token"  # Get from Cloudflare dashboard
cloudflare_zone_id   = "your-cloudflare-zone-id"    # Find in Cloudflare zone overview

# Application paths (defaults should work if placeholder apps are built)
react_build_path = "../../apps/placeholder-app/dist"
lambda_zip_path  = "../../apps/placeholder-api/lambda-deployment.zip"

# Resource tags
tags = {
  Project     = "yourapp"  # Replace with your application name
  Environment = "sbx"
  ManagedBy   = "terraform"
  Owner       = "devops"
}