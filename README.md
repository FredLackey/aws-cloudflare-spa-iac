# Multi-Environment AWS Application Deployment

A complete Infrastructure as Code (IaC) template for deploying modern web applications using AWS and Cloudflare. This repository provides a production-ready architecture that separates infrastructure provisioning from application deployment.

## Background

This repo was built to help other developers use IaC and CI/CD in their personal apps.  A more detailed explaination is in the [ABOUT.md](ABOUT.md) page.  Contact info is at the bottom of the page if you need a hand.

## Features

- **Full-Stack Architecture**: React frontend with Node.js API backend
- **SSL Certificate Management**: Automated certificate provisioning and validation via Cloudflare
- **Global Content Delivery**: CloudFront CDN for optimal performance
- **Infrastructure as Code**: Terraform-managed, version-controlled infrastructure
- **Deployment Separation**: Independent infrastructure setup and application deployment workflows
- **Multi-Environment Support**: Consistent deployment patterns across development, staging, and production

## Architecture Overview

This template uses a dual-provider approach combining Cloudflare and AWS:

**Cloudflare**
- DNS management and domain validation
- SSL certificate validation via DNS challenges

**AWS Services**
- **Lambda**: Serverless Node.js API runtime
- **S3 + CloudFront**: Static site hosting and global content delivery
- **ACM**: SSL certificate management
- **IAM**: Access control and permissions

**Technology Stack**
- Frontend: React 19 with Vite build tooling
- Backend: Node.js 20 on AWS Lambda
- Infrastructure: Terraform for declarative resource management

## Deployment Model

### Phase 1: Infrastructure Setup (One-Time)
1. **Certificate Provisioning** (`iac-cert-dns`): Creates and validates SSL certificates
2. **Infrastructure Provisioning** (`iac-env-hosting`): Deploys Lambda functions, S3 buckets, CloudFront distributions, and supporting resources

### Phase 2: Application Deployment (Ongoing)
3. **Backend Updates** (`iac-app-lambda`): Updates Lambda function code without infrastructure changes
4. **Frontend Updates** (`iac-app-cloudfront`): Updates S3 content and invalidates CloudFront cache

This separation allows infrastructure teams to manage foundational resources while development teams can deploy application changes independently.

## Project Structure

```
├── iac/                        # Infrastructure as Code packages
│   ├── iac-cert-dns/          # SSL certificate management
│   ├── iac-env-hosting/       # Core infrastructure provisioning
│   ├── iac-app-lambda/        # Lambda function deployments
│   └── iac-app-cloudfront/    # Frontend deployments
└── apps/                      # Application code
    ├── placeholder-api/       # Node.js API template
    └── placeholder-app/       # React frontend template
```

### Package Responsibilities

| Package | Owner | Purpose |
|---------|-------|---------|
| `iac-cert-dns` | Cloud Owner | SSL certificate provisioning and DNS validation |
| `iac-env-hosting` | DevOps | Complete infrastructure setup including Lambda, S3, CloudFront, and IAM resources |
| `iac-app-lambda` | Developer | Lambda function code updates (no infrastructure changes) |
| `iac-app-cloudfront` | Developer | Frontend content updates and cache invalidation |

## Configuration Requirements

Before deployment, configure these placeholder values throughout the project:

| Placeholder | Description | Example |
|-------------|-------------|---------|
| `your-aws-profile-name` | AWS CLI profile name | `my-project-dev` |
| `your-cloudflare-api-token` | Cloudflare API token with Zone:Edit permissions | Generated from Cloudflare dashboard |
| `your-cloudflare-zone-id` | Cloudflare zone identifier | Found in domain overview |
| `yourdomain.com` | Your actual domain name | `example.com` |
| `yourapp` | Application/product identifier for AWS resources | `myapp` |
| `123456789012` | Your AWS account ID | Your actual account number |

### Environment Variables

Set these before running Terraform commands:

```bash
export AWS_PROFILE=your-aws-profile-name
export TF_VAR_environment=sbx
export CLOUDFLARE_API_TOKEN=your-cloudflare-api-token
export CLOUDFLARE_ZONE_ID=your-cloudflare-zone-id
```

## Domain Configuration

Applications are served from environment-specific subdomains:

| Environment | Domain Pattern | Example |
|-------------|---------------|---------|
| Production | `app.yourdomain.com` | `app.example.com` |
| Other environments | `app-<env>.yourdomain.com` | `app-staging.example.com` |

## Resource Naming Convention

All AWS resources follow a consistent naming pattern to prevent conflicts in shared accounts:

**Format**: `<app-name>-<purpose>-<environment>`

**Examples**:
- S3 Bucket: `myapp-frontend-prod`
- Lambda Function: `myapp-api-staging`
- IAM Role: `myapp-lambda-execution-dev`

## Terraform State Management

Each package maintains separate Terraform state for better isolation:

| Package | State Bucket Format | Purpose |
|---------|-------------------|---------|
| `iac-cert-dns` | `tfstate-yourapp-cert-<env>` | Certificate management |
| `iac-env-hosting` | `tfstate-yourapp-hosting-<env>` | Infrastructure provisioning |
| `iac-app-lambda` | `tfstate-yourapp-lambda-<env>` | Lambda deployments |
| `iac-app-cloudfront` | `tfstate-yourapp-cloudfront-<env>` | Frontend deployments |

## Deployment Process

### Initial Setup

1. **Configure prerequisites**: AWS CLI, Cloudflare API access, and domain ownership
2. **Update configuration**: Replace placeholder values in terraform.tfvars files
3. **Deploy certificates**: Run `iac-cert-dns` package
4. **Provision infrastructure**: Run `iac-env-hosting` package

### Application Updates

- **Backend changes**: Use `iac-app-lambda` package
- **Frontend changes**: Use `iac-app-cloudfront` package

## Output Tracking

Each package generates `outputs.json` files containing:
- Resource identifiers and ARNs
- Deployment timestamps
- Cross-package dependencies
- Resource metadata for debugging and auditing

## Benefits

**Security**
- Developers cannot modify infrastructure resources
- Separate IAM permissions for infrastructure vs. application deployments
- Automated SSL certificate management

**Operational Efficiency**
- Fast application deployments without infrastructure planning overhead
- Clear separation of responsibilities between teams
- Consistent deployment patterns across environments

**Scalability**
- Serverless architecture with automatic scaling
- Global content delivery via CloudFront
- Support for multiple environments and applications

**Cost Management**
- Pay-per-use serverless pricing
- Efficient CDN caching reduces origin requests
- No idle resource costs

## Documentation

Detailed instructions for each component are available in their respective directories:

- Certificate management: `iac/iac-cert-dns/README.md`
- Infrastructure setup: `iac/iac-env-hosting/README.md`
- Lambda deployments: `iac/iac-app-lambda/README.md`
- Frontend deployments: `iac/iac-app-cloudfront/README.md`

## Contact Info & Assistance  

If you get stuck, or have an idea for an improvement, please feel free to reach out.  

**Fred Lackey**  
[fred.lackey@gmail.com](mailto:fred.lackey@gmail.com)  
[https://fredlackey.com](https://fredlackey.com)  