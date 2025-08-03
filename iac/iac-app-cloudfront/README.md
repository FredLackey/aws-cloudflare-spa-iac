# `iac-app-cloudfront`

This Terraform package is owned by the **Developer** team and is responsible for updating frontend content only. It assumes that all necessary infrastructure (S3 bucket, CloudFront distribution, ACM certificates, etc.) has already been provisioned by the DevOps team via `iac-env-hosting`.

---

## 🔐 Purpose

This package:
- **Updates S3 bucket content** (uploads new frontend build files)
- **Invalidates CloudFront cache** to serve updated content
- **Does NOT create or modify any infrastructure**
- **Does NOT manage certificates or distributions**
- Allows developers to deploy frontend changes without affecting infrastructure

---

## 👤 Owner

**Team**: Developer  
**Account**: Hosting account (your AWS account)  
**Role**: Can update S3 content and invalidate CloudFront cache only, cannot provision or modify infrastructure

---

## 🧱 Components

| Resource                   | Description                                       |
|----------------------------|---------------------------------------------------|
| `data.aws_s3_bucket`      | **Read-only reference** to existing S3 bucket created by DevOps |
| `data.aws_cloudfront_distribution` | **Read-only reference** to existing CloudFront distribution |
| `aws_s3_bucket_object`    | Updates static files in the existing bucket |
| `null_resource`           | Executes CloudFront cache invalidation commands |
| `local_file`              | Generates required `outputs.json` file for tracking |

**Note**: No S3 buckets, CloudFront distributions, or other infrastructure is created - these already exist from DevOps provisioning.

---

## 🔁 Workflow

1. **Prerequisites**: DevOps has already created S3 bucket and CloudFront distribution via `iac-env-hosting`
2. **Developer builds** frontend project locally (e.g., `npm run build`)
3. **Developer runs** `terraform apply` to upload new files to S3
4. **CloudFront cache invalidation** runs automatically to serve new content

**No infrastructure changes** - the existing S3 bucket, CloudFront distribution, and DNS continue to work exactly the same.

---

## ⚠️ CRITICAL: Frontend-Backend Compatibility

**DEVELOPER RESPONSIBILITY**: When updating frontend code, you **MUST** ensure:

- **No Breaking Changes**: Frontend must remain compatible with existing backend API endpoints
- **Thorough Testing**: Test all API integrations locally before deployment
- **Backend Coordination**: Coordinate with backend developers if API changes are needed
- **Graceful Degradation**: Handle API changes gracefully to avoid breaking user experience

**Breaking frontend-backend compatibility will immediately break the live application since frontend and backend are deployed independently.**

---

## 📥 Inputs

```hcl
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
```

**Note**: No certificate ARN, domain name, or infrastructure-related variables needed - these are already configured by DevOps.

---

## 📤 Outputs

### Terraform Outputs (`outputs.tf`)
```hcl
output "bucket_name" {
  description = "S3 bucket name (from existing bucket)"
  value       = data.aws_s3_bucket.existing.bucket
}

output "distribution_id" {
  description = "CloudFront distribution ID (from existing distribution)"
  value       = data.aws_cloudfront_distribution.existing.id
}

output "distribution_domain_name" {
  description = "CloudFront distribution domain name (from existing distribution)"
  value       = data.aws_cloudfront_distribution.existing.domain_name
}

output "content_update_trigger" {
  description = "Timestamp that triggers content updates"
  value       = null_resource.invalidate_cache.id
}
```

### Required Output File (`outputs.json`)
**MANDATORY**: This package must generate `outputs.json` with:
```json
{
  "package_name": "iac-app-cloudfront",
  "environment": "${var.environment}",
  "timestamp": "2024-01-15T10:30:00Z",
  "resources_updated": {
    "s3_buckets": [
      {
        "name": "yourapp-frontend-sbx",
        "files_updated": true,
        "last_sync": "2024-01-15T10:30:00Z"
      }
    ],
    "cloudfront_distributions": [
      {
        "id": "E1234567890ABC",
        "cache_invalidated": true,
        "last_invalidation": "2024-01-15T10:30:00Z"
      }
    ]
  },
  "terraform_outputs": {
    "bucket_name": "yourapp-frontend-sbx",
    "distribution_id": "E1234567890ABC"
  }
}
```

**Note**: This shows `resources_updated` (not `resources_created`) since no new infrastructure is created.

---

## 🚨 Notes

- **Content Only**: This package only updates S3 content and invalidates CloudFront cache - no infrastructure changes
- **DevOps Handoff**: Get the exact bucket name and distribution ID from the DevOps team's `iac-env-hosting` outputs
- **No Downtime**: CloudFront distribution continues serving from the same domain
- **Build Locally**: Frontend assets should be built locally before `terraform apply`
- **Cache Invalidation**: Automatically invalidates CloudFront cache to serve new content immediately
- **⚠️ DEVELOPER RESPONSIBILITY**: It is the developer's responsibility to ensure that any frontend changes do **NOT** break compatibility with the existing backend API. Test thoroughly before deploying.

---

## 🧪 Example Usage

```bash
# Step 1: Setup state bucket (one-time setup)
cd iac/iac-app-cloudfront/
./scripts/setup-state-bucket.sh your-aws-profile-name

# Step 2: Get bucket name and distribution ID from DevOps team
# (Check iac-env-hosting outputs or ask DevOps for exact values)

# Step 3: Build your updated frontend code
cd ../../apps/your-actual-app/
npm run build

# Step 4: Update the S3 content and invalidate CloudFront cache
cd ../../iac/iac-app-cloudfront/
terraform init
terraform apply
```

### 📝 Note on Example Configuration

The current example configuration uses `../../apps/placeholder-app/dist` as a placeholder. **Development teams should replace this with the path to their actual application's build directory.**

For example:
- Replace `placeholder-app` with your actual frontend project directory name
- Ensure your build directory contains your compiled application assets
- Update the `source_dir` variable in your `terraform.tfvars` accordingly

---

## 🧭 Prerequisites

- **Completed DevOps Setup**: `iac-env-hosting` must be successfully deployed first
- **Bucket Name**: Exact S3 bucket name from DevOps team (e.g., `yourapp-frontend-sbx`)
- **Distribution ID**: CloudFront distribution ID from DevOps team (e.g., `E1234567890ABC`)
- **AWS Credentials**: Access to the target hosting account with profile `your-aws-profile-name`
- **Terraform ≥ 1.3.x**
- **AWS CLI**: For the CloudFront invalidation commands executed by `null_resource`
- **Built Assets**: Compiled SPA assets ready for deployment

---

## 🗂️ Terraform Backend Configuration

This package uses remote state stored in **Amazon S3** with **DynamoDB** state locking:

- **S3 Bucket**: `tfstate-yourapp-cloudfront-sbx`
- **DynamoDB Table**: `tfstate-yourapp-cloudfront-sbx`
- **State Key**: `iac-app-cloudfront/terraform.tfstate`

Use the provided setup script to create these resources:

```bash
./scripts/setup-state-bucket.sh your-aws-profile-name
```

## Contact Info & Assistance  

If you get stuck, or have an idea for an improvement, please feel free to reach out.  

**Fred Lackey**  
[fred.lackey@gmail.com](mailto:fred.lackey@gmail.com)  
[https://fredlackey.com](https://fredlackey.com)
