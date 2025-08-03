terraform {
  backend "s3" {
    # Replace yourapp with your application name and update profile
    bucket         = "tfstate-yourapp-lambda-sbx"
    key            = "iac-app-lambda/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tfstate-yourapp-lambda-sbx"
    encrypt        = true
    profile        = "your-aws-profile-name"  # Replace with your AWS profile
  }
}