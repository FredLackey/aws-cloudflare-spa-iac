terraform {
  backend "s3" {
    # Replace yourapp with your application name and update profile
    bucket         = "tfstate-yourapp-cloudfront-sbx"
    key            = "iac-app-cloudfront/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tfstate-yourapp-cloudfront-sbx"
    encrypt        = true
    profile        = "your-aws-profile-name"  # Replace with your AWS profile
  }
}