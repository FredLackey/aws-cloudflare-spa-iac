# PLACEHOLDER VALUES - Replace with your actual configuration
# Environment configuration
environment = "sbx"

# S3 bucket name from DevOps team (iac-env-hosting output)
# Get this value after running iac-env-hosting: terraform output s3_bucket_name
bucket_name = "yourapp-frontend-sbx"  # Replace yourapp with your application name

# CloudFront distribution ID from DevOps team (iac-env-hosting output)  
# Get this value after running iac-env-hosting: terraform output cloudfront_distribution_id
distribution_id = "YOUR_DISTRIBUTION_ID"  # Replace with actual distribution ID

# Path to your application's build directory
# Replace with your actual frontend project path
source_dir = "../../apps/mock-real-app/dist"