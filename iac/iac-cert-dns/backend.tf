terraform {
  backend "s3" {
    # Replace yourapp with your application name and update profile
    bucket         = "tfstate-yourapp-cert-sbx"
    key            = "iac-cert-dns/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tfstate-yourapp-cert-sbx"
    encrypt        = true
    profile        = "your-aws-profile-name"  # Replace with your AWS profile
  }
}