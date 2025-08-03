# `iac-env-hosting`

This Terraform package provisions environment-specific infrastructure inside the **existing hosting account** for your application. It is executed by the **DevOps** team and focuses on preparing all hosting infrastructure that developers will consume during CICD processes. This includes Lambda functions, S3 buckets, CloudFront distributions, databases, and other resources needed for application deployment.

---

## 🔐 Purpose

This package:
- **Prepares infrastructure** for Lambda deployments (functions, execution roles)
- **Prepares infrastructure** for S3/CloudFront hosting (buckets, distributions, behaviors)
- Connects CloudFront distributions to the provided ACM certificate
- Configures CloudFront behaviors to forward `/api/*` requests to Lambda Function URLs
- **Creates DNS CNAME record** pointing custom domain to CloudFront distribution
- Creates database instances and other supporting resources (future scope)
- Deploys initial **placeholder applications** to validate infrastructure
- Exposes all outputs necessary for developers to deploy applications via CICD

---

## 👤 Owner

**Team**: DevOps  
**Account**: Hosting account (Your AWS Account, ID: 123456789012)  
**Role**: Provision cloud resources for your application

---

## 🧱 Components

| Resource                        | Description                                           |
|---------------------------------|-------------------------------------------------------|
| `aws_s3_bucket`                | Stores the compiled React front-end (`yourapp-frontend-sbx`) |
| `aws_s3_bucket_object`         | Uploads React assets from the provided build folder  |
| `aws_cloudfront_distribution`  | Public CDN for the front-end app                     |
| `aws_cloudfront_behavior`      | Routes `/api/*` requests to the Lambda Function URL  |
| `aws_lambda_function`          | Deploys the placeholder Express.js API (`yourapp-api-sbx`) |
| `aws_lambda_function_url`      | Enables direct HTTP access to Lambda for CloudFront  |
| `aws_iam_role`                 | Execution role for Lambda (`yourapp-lambda-execution-sbx`) |
| `aws_acm_certificate`          | Referenced from Cloud Owner provisioning             |
| `cloudflare_record`            | CNAME record pointing custom domain to CloudFront    |

---

## 🔁 Terraform Execution

Terraform handles resource dependencies automatically. The key dependencies are:

- **CloudFront behaviors** depend on **Lambda Function URL** (via resource references)
- **Lambda function** depends on **IAM execution role** 
- **CloudFront distribution** depends on **ACM certificate ARN** (from `iac-cert-dns` outputs)
- **S3 bucket objects** depend on **S3 bucket** creation

Terraform will create resources in the correct order based on these dependencies. A typical `terraform apply` will:

1. Create IAM roles and S3 buckets (no dependencies)
2. Deploy Lambda function (depends on IAM role)
3. Create Lambda Function URL (depends on Lambda function)
4. Create CloudFront distribution with behaviors (depends on certificate + Lambda URL)
5. Upload S3 objects (depends on S3 bucket)

---

## 🔧 API Requirements

The backend API is built using **Node.js + Express** and deployed via Lambda using `aws-serverless-express`. To support CloudFront routing and browser clients:

- The Express app **must handle CORS** directly
- DevOps should default CORS to allow all origins:
  ```js
  const cors = require('cors');
  app.use(cors()); // allows all origins for early development and testing
  ```
- Developers are responsible for replacing this with environment-specific CORS rules before production:
  ```js
  app.use(cors({
    origin: ['https://app.yourdomain.com'],
    methods: ['GET', 'POST'],
    credentials: true
  }));
  ```
- You may optionally configure CORS origins via environment variable:
  ```js
  const allowedOrigins = process.env.CORS_ORIGINS?.split(',') || ['*'];
  app.use(cors({ origin: allowedOrigins }));
  ```

> CloudFront does not enforce CORS — the Lambda function must return correct headers in all responses, including preflight `OPTIONS` requests.

---

## ✅ API Health Test

After deployment, you can verify the Lambda API is working correctly **without relying on CloudFront** by calling the Function URL directly:

```bash
curl -i https://<lambda-function-id>.lambda-url.<region>.on.aws/api/status
```

This helps confirm that the Lambda deployment and basic routing are functioning even if CloudFront configuration is still in progress or fails.

---

## 🔗 Prerequisites

This package requires outputs from the **`iac-cert-dns`** package to be completed first.

### Required from iac-cert-dns Package

Before running this package, ensure the `iac-cert-dns` package has been successfully applied and obtain:

1. **Certificate ARN** - The ARN of the validated ACM certificate
   - Example: `arn:aws:acm:us-east-1:123456789012:certificate/abc123-def456-ghi789`
   - Found in: `iac-cert-dns` Terraform outputs or `outputs.json`

2. **Certificate Status** - Verify the certificate is `ISSUED`
   - Check via: AWS Console → Certificate Manager or `terraform output` in iac-cert-dns

### How to Get These Values

**Option 1: From Terraform outputs**
```bash
cd iac/iac-cert-dns
terraform output certificate_arn
```

**Option 2: From outputs.json file**
```bash
cat iac/iac-cert-dns/outputs.json | jq -r '.terraform_outputs.certificate_arn'
```

**Option 3: AWS CLI**
```bash
aws acm list-certificates --region us-east-1 --query 'CertificateSummaryList[?DomainName==`app-sbx.yourdomain.com`].CertificateArn' --output text
```

---

## 📥 Inputs

```hcl
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
```

---

## 📤 Outputs

### Terraform Outputs (`outputs.tf`)
```hcl
output "cloudfront_domain_name" {
  description = "Public CloudFront domain for the front-end"
  value       = aws_cloudfront_distribution.app.domain_name
}

output "lambda_function_url" {
  description = "Direct URL endpoint for the backend Lambda"
  value       = aws_lambda_function_url.api.function_url
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket hosting the frontend"
  value       = aws_s3_bucket.frontend.bucket
}

output "lambda_function_name" {
  description = "Name of the deployed Lambda function"
  value       = aws_lambda_function.api.function_name
}

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.app.id
}

output "custom_domain_name" {
  description = "Custom domain name pointing to CloudFront"
  value       = cloudflare_record.app_dns.hostname
}

output "dns_record_id" {
  description = "Cloudflare DNS record ID"
  value       = cloudflare_record.app_dns.id
}
```

### Required Output File (`outputs.json`)
**MANDATORY**: This package must generate `outputs.json` with:
```json
{
  "package_name": "iac-env-hosting",
  "environment": "${var.environment}",
  "timestamp": "2024-01-15T10:30:00Z",
  "resources_created": {
    "s3_buckets": [
      {
        "name": "yourapp-frontend-sbx",
        "purpose": "frontend-hosting",
        "region": "us-east-1"
      }
    ],
    "lambda_functions": [
      {
        "name": "yourapp-api-sbx",
        "function_url": "https://abc123.lambda-url.us-east-1.on.aws/",
        "runtime": "nodejs20.x"
      }
    ],
    "cloudfront_distributions": [
      {
        "id": "E123456789",
        "domain_name": "d123456.cloudfront.net",
        "custom_domain": "app-sbx.yourdomain.com"
      }
    ]
  },
  "terraform_outputs": {
    "cloudfront_domain_name": "d123456.cloudfront.net",
    "lambda_function_url": "https://abc123.lambda-url.us-east-1.on.aws/"
  }
}
```

---

## 🚨 Notes & Architecture

### Infrastructure Preparation vs. CICD Deployment

This package serves as **infrastructure preparation** by the DevOps team. It creates and configures all the hosting resources that developers need. After this package runs:

- **`iac-app-lambda`** - Used by developers during CICD to update Lambda function code without touching infrastructure
- **`iac-app-cloudfront`** - Used by developers during CICD to update S3 content and CloudFront invalidations without modifying distributions

### Key Points

- Lambda functions and S3/CloudFront resources are created as **infrastructure**
- Initial placeholder applications are deployed to **validate** the infrastructure works
- This package **does not** manage DNS — DNS records are handled in `iac-cert-dns`
- All `/api/*` traffic is routed to Lambda backends via CloudFront behaviors
- Future database instances will be provisioned here as **infrastructure**

---

## 🗂️ Terraform Backend Configuration

This package uses remote state stored in **Amazon S3** with **DynamoDB** state locking:

- **S3 Bucket**: `tfstate-yourapp-hosting-sbx`
- **DynamoDB Table**: `tfstate-yourapp-hosting-sbx`
- **State Key**: `iac-env-hosting/terraform.tfstate`

**Example `backend.tf`:**
```hcl
terraform {
  backend "s3" {
    bucket         = "tfstate-yourapp-hosting-sbx"
    key            = "iac-env-hosting/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tfstate-yourapp-hosting-sbx"
    encrypt        = true
  }
}
```

---

## 🧪 Example Usage

### Step 1: Setup Backend Resources
```bash
cd iac/iac-env-hosting
./scripts/setup-state-bucket.sh your-aws-profile-name
```

### Step 2: Get Certificate ARN from Previous Package
```bash
# Get the certificate ARN from iac-cert-dns
cd ../iac-cert-dns
CERT_ARN=$(terraform output -raw certificate_arn)
cd ../iac-env-hosting
```

### Step 3: Create terraform.tfvars
```hcl
# terraform.tfvars
environment     = "sbx"
certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/abc123-def456-ghi789"

# CloudWatch log retention (7 days for sandbox)
log_retention_days = 7

# Cloudflare DNS configuration
cloudflare_api_token = "your-cloudflare-api-token"
cloudflare_zone_id   = "your-zone-id"

# Application paths (defaults should work if placeholder apps are built)
react_build_path = "../../apps/placeholder-app/dist"
lambda_zip_path  = "../../apps/placeholder-api/lambda-deployment.zip"

tags = {
  Project     = "yourapp"
  Environment = "sbx"
  ManagedBy   = "terraform"
  Owner       = "devops"
}
```

### Step 4: Deploy Infrastructure
```bash
terraform init
terraform plan    # Review what will be created
terraform apply   # Deploy the infrastructure
```

### Step 5: Verify Deployment
```bash
# Test Lambda directly
LAMBDA_URL=$(terraform output -raw lambda_function_url)
curl -i "${LAMBDA_URL}api/status"

# Test through CloudFront
CLOUDFRONT_DOMAIN=$(terraform output -raw cloudfront_domain_name)
curl -i "https://${CLOUDFRONT_DOMAIN}/api/status"
```

---

For questions, contact the DevOps team responsible for your application environment.

## Contact Info & Assistance  

If you get stuck, or have an idea for an improvement, please feel free to reach out.  

**Fred Lackey**  
[fred.lackey@gmail.com](mailto:fred.lackey@gmail.com)  
[https://fredlackey.com](https://fredlackey.com)
