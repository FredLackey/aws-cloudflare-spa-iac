# `iac-cert-dns`

This Terraform package provisions public ACM certificates for the `yourdomain.com` domain and handles domain validation via DNS using Cloudflare. It is intended to be executed by the **Cloud Owner** team.

---

## 🎯 Primary Goal

**Create ACM certificates in the AWS hosting account that can be used by future CloudFront distributions, using Cloudflare for DNS-based domain validation.**

This package bridges the two-account architecture by:
- Provisioning certificates in AWS (where they must reside for CloudFront)
- Leveraging Cloudflare DNS for automated domain validation
- Outputting certificate ARNs for downstream infrastructure packages

---

## 🔐 Purpose

This package:
- Requests ACM certificates in the **hosting account** for one or more domain names (e.g., `*.yourdomain.com`)
- Creates DNS records in **Cloudflare** to validate ownership
- Outputs the ARN of each certificate for downstream use in ALB and CloudFront distributions

## 🏗️ Two-Provider Architecture

This package requires access to **both** providers within Terraform:

1. **AWS Provider** - Creates ACM certificates in the hosting account
2. **Cloudflare Provider** - Manages DNS records for certificate validation

This dual-provider approach enables:
- Certificates to reside in AWS (required for CloudFront/ALB)
- DNS validation through Cloudflare (domain registrar)
- Automated certificate lifecycle management

---

## 👤 Owner

**Team**: Cloud Owner  
**Account(s)**: Hosting account (where ACM certs will reside), but uses Cloudflare credentials for validation  
**Role**: Has write access to Cloudflare DNS zone and permission to provision ACM resources in the hosting account

## 🏢 Multi-Product Environment Considerations

**IMPORTANT**: The AWS hosting account may contain multiple products. When creating ACM certificates:

- **Certificate names** should be domain-based (naturally unique): `app-sbx.yourdomain.com`
- **Tags** must include product identification: `Product = "yourapp"`
- **Resource naming** should follow the pattern: `yourapp-cert-<purpose>-<env>` (e.g., `yourapp-cert-app-sbx`)

This prevents conflicts with other products' certificates in the same hosting account.

---

## 🧱 Components

| Resource                        | Description                                         |
|---------------------------------|-----------------------------------------------------|
| `aws_acm_certificate`          | Requests the certificate from AWS Certificate Manager |
| `cloudflare_record`            | Creates `_acme-challenge` TXT records for validation |
| `aws_acm_certificate_validation` | Validates the certificate once DNS is available    |
| `outputs.tf`                   | Exposes certificate ARNs for use by DevOps & Developers |

---

## 🔁 Workflow

1. **Run this package first** before any ALB or CloudFront infrastructure is created
2. Terraform will:
   - Request the certificate in AWS
   - Create DNS validation records in Cloudflare
   - Wait for ACM to confirm ownership
3. The resulting certificate ARN will be used later by the DevOps and Developer teams

---

## 📥 Inputs

You can customize the following variables:

```hcl
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
  default     = {}
}
```

---

## 📤 Outputs

### Terraform Outputs (`outputs.tf`)
```hcl
output "certificate_arn" {
  description = "ARN of the validated ACM certificate"
  value       = aws_acm_certificate_validation.this.certificate_arn
}

output "certificate_domain_validation_options" {
  description = "Domain validation options used for the certificate"
  value       = aws_acm_certificate.this.domain_validation_options
}

output "certificate_status" {
  description = "Status of the certificate"
  value       = aws_acm_certificate_validation.this.certificate_arn != null ? "ISSUED" : "PENDING"
}
```

### Required Output File (`outputs.json`)
**MANDATORY**: This package must generate `outputs.json` with:
```json
{
  "package_name": "iac-cert-dns",
  "environment": "${var.environment}",
  "timestamp": "2024-01-15T10:30:00Z",
  "resources_created": {
    "certificates": [
      {
        "domain": "app-sbx.yourdomain.com",
        "arn": "arn:aws:acm:us-east-1:123456789012:certificate/abc123",
        "status": "ISSUED",
        "region": "us-east-1",
        "validation_method": "DNS"
      }
    ],
    "dns_records": [
      {
        "name": "_acme-challenge.app-sbx.yourdomain.com",
        "type": "TXT",
        "cloudflare_record_id": "rec_123456789"
      }
    ]
  },
  "terraform_outputs": {
    "certificate_arn": "arn:aws:acm:us-east-1:123456789012:certificate/abc123"
  }
}
```

These outputs enable downstream packages (`iac-app-cloudfront`, `iac-env-hosting`) to reference the certificate ARN for CloudFront distributions and ALB configurations.

---

## 🚨 Notes

- Certificate **must** be created in the **same AWS region** as the service that will use it:
  - Use `us-east-1` for **CloudFront**
  - Match region of ALB (e.g., `us-west-2`) if using with **ALB**
- ACM certificates are **free** but must be renewed every 13 months
- Terraform will manage renewal as long as the state is preserved

---

## 🗂️ Terraform Backend Configuration

This package uses remote state stored in **Amazon S3** with **DynamoDB** state locking:

- **S3 Bucket**: `tfstate-yourapp-cert-sbx`
- **DynamoDB Table**: `tfstate-yourapp-cert-sbx`
- **State Key**: `iac-cert-dns/terraform.tfstate`

The backend configuration should be defined in `backend.tf` or `terraform.tf`.

---

## 🧪 Example Usage

```bash
# Navigate into the package directory
cd iac-cert-dns/

# Initialize Terraform (reads backend.tf automatically)
terraform init

# Plan and apply
terraform plan
terraform apply
```

### Configuration Files

The package should include these configuration values:

**`terraform.tfvars`:**
```hcl
environment = "sbx"
cloudflare_api_token = "your-cloudflare-api-token"
```

**`providers.tf`:**
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "your-aws-profile-name"
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
```

**`backend.tf`:**
```hcl
terraform {
  backend "s3" {
    bucket         = "tfstate-yourapp-cert-sbx"
    key            = "iac-cert-dns/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tfstate-yourapp-cert-sbx"
    encrypt        = true
  }
}
```

---

## 🧭 Prerequisites

- Cloudflare API Token with permissions:
  - Zone:DNS:Edit
- AWS credentials for the target hosting account
- Terraform ≥ 1.3.x

---

For questions or updates to DNS scope, contact the Cloud Owner team.

## Contact Info & Assistance  

If you get stuck, or have an idea for an improvement, please feel free to reach out.  

**Fred Lackey**  
[fred.lackey@gmail.com](mailto:fred.lackey@gmail.com)  
[https://fredlackey.com](https://fredlackey.com)
