# `iac-app-lambda`

This Terraform package is owned by the **Developer** team and is responsible for updating Lambda function code only. It assumes that all necessary infrastructure (Lambda functions, execution roles, CloudWatch logs, etc.) has already been provisioned by the DevOps team via `iac-env-hosting`.

---

## 🔐 Purpose

This package:
- **Updates Lambda function code** (replaces deployment package)
- **Does NOT create or modify any infrastructure**
- **Does NOT use versions or aliases**
- Allows developers to deploy code changes without affecting CloudFront distributions or other infrastructure

---

## 👤 Owner

**Team**: Developer  
**Account**: Hosting account (your AWS account)  
**Role**: Can update Lambda function code only, cannot provision or modify infrastructure

---

## 🧱 Components

| Resource                  | Description                                       |
|---------------------------|---------------------------------------------------|
| `data.aws_lambda_function` | **Read-only reference** to existing Lambda function created by DevOps |
| `null_resource` | Executes AWS CLI commands to update Lambda function code only |
| `local_file` | Generates required `outputs.json` file for tracking |

**Note**: No Lambda functions, IAM roles, CloudWatch logs, or other infrastructure is created - these already exist from DevOps provisioning.

---

## 🔁 Workflow

1. **Prerequisites**: DevOps has already created Lambda function via `iac-env-hosting`
2. **Developer builds** updated Lambda code (e.g., Node.js zip bundle)  
3. **Developer runs** `terraform apply` to update function code
4. **CloudFront distribution continues working** - same Function URL, same routing, just new code

**No infrastructure changes** - the existing CloudFront distribution, Function URL, and all routing continue to work exactly the same.

---

## ⚠️ CRITICAL: API Contract Compatibility

**DEVELOPER RESPONSIBILITY**: When updating Lambda function code, you **MUST** ensure:

- **No Breaking Changes**: API endpoints, request/response formats, and behavior remain compatible with the existing UI
- **Thorough Testing**: Test all API endpoints locally before deployment 
- **Backward Compatibility**: Any new features should be additive, not replacing existing functionality
- **UI Coordination**: Coordinate with frontend developers if API changes are needed

**Breaking the API contract will immediately break the live UI since both are deployed independently.**

---

## 📥 Inputs

```hcl
variable "function_name" {
  description = "Name of existing Lambda function (provided by DevOps team)"
  type        = string
  # Example: "yourapp-api-sbx"
}

variable "lambda_source_path" {
  description = "Path to the zipped deployment package with updated code"
  type        = string
  # Example: "../../apps/your-actual-api/lambda-deployment.zip"
}

variable "environment_variables" {
  description = "Environment variables for the function (optional updates)"
  type        = map(string)
  default     = {}
}
```

**Note**: No `handler`, `runtime`, or infrastructure-related variables needed - these are already configured by DevOps.

---

## 📤 Outputs

### Terraform Outputs (`outputs.tf`)
```hcl
output "function_name" {
  description = "Lambda function name (from existing function)"
  value       = data.aws_lambda_function.existing.function_name
}

output "function_arn" {
  description = "ARN of the Lambda function (from existing function)"
  value       = data.aws_lambda_function.existing.arn
}

output "code_update_trigger" {
  description = "Hash that triggers code updates"
  value       = null_resource.update_code.triggers.code_hash
}
```

### Required Output File (`outputs.json`)
**MANDATORY**: This package must generate `outputs.json` with:
```json
{
  "package_name": "iac-app-lambda",
  "environment": "${var.environment}",
  "timestamp": "2024-01-15T10:30:00Z",
  "resources_updated": {
    "lambda_functions": [
      {
        "name": "yourapp-api-sbx",
        "arn": "arn:aws:lambda:us-west-2:123456789012:function:yourapp-api-sbx",
        "last_modified": "2024-01-15T10:30:00Z",
        "code_updated": true
      }
    ]
  },
  "terraform_outputs": {
    "function_name": "yourapp-api-sbx",
    "function_arn": "arn:aws:lambda:us-west-2:123456789012:function:yourapp-api-sbx"
  }
}
```

**Note**: This shows `resources_updated` (not `resources_created`) since no new infrastructure is created.

---

## 🚨 Notes

- **Code Only**: This package only updates Lambda function code - no infrastructure changes
- **DevOps Handoff**: Get the exact function name from the DevOps team's `iac-env-hosting` outputs
- **No Downtime**: Function URL remains the same, so CloudFront routing is unaffected
- **Zip Locally**: Lambda code should be zipped locally before `terraform apply`
- **No Versioning**: Updates function directly without versions or aliases
- **⚠️ DEVELOPER RESPONSIBILITY**: It is the developer's responsibility to ensure that any code changes deployed do **NOT** cause breaking changes with the existing UI. Test thoroughly before deploying to avoid API contract violations that could break the frontend application.

---

## 🧪 Example Usage

```bash
# Step 1: Setup state bucket (one-time setup)
cd iac/iac-app-lambda/
./scripts/setup-state-bucket.sh your-aws-profile-name

# Step 2: Get function name from DevOps team
# (Check iac-env-hosting outputs or ask DevOps for the exact function name)

# Step 3: Build and zip your updated Lambda code
cd ../../apps/your-actual-api/
npm run build
zip -r lambda-deployment.zip .

# Step 4: Update the Lambda function code
cd ../../iac/iac-app-lambda/
terraform init
terraform apply
```

### 📝 Note on Example Configuration

The current example configuration uses `../../apps/mock-real-api/lambda-deployment.zip` as a placeholder. **Development teams should replace this with the path to their actual application's zip file.**

For example:
- Replace `mock-real-api` with your actual API project directory name
- Ensure your zip file contains your built application code
- Update the `lambda_source_path` variable in your `terraform.tfvars` accordingly

---

## 🧭 Prerequisites

- **Completed DevOps Setup**: `iac-env-hosting` must be successfully deployed first
- **Function Name**: Exact Lambda function name from DevOps team (e.g., `yourapp-api-sbx`)
- **AWS Credentials**: Access to the target hosting account with profile `your-aws-profile-name`
- **Terraform ≥ 1.3.x**
- **AWS CLI**: For the code update commands executed by `null_resource`
- **Built Code**: Zipped Lambda deployment package ready

---

## 🗂️ Terraform Backend Configuration

This package uses remote state stored in **Amazon S3** with **DynamoDB** state locking:

- **S3 Bucket**: `tfstate-yourapp-lambda-sbx`
- **DynamoDB Table**: `tfstate-yourapp-lambda-sbx`
- **State Key**: `iac-app-lambda/terraform.tfstate`

Use the provided setup script to create these resources:

```bash
./scripts/setup-state-bucket.sh your-aws-profile-name
```

## Contact Info & Assistance  

If you get stuck, or have an idea for an improvement, please feel free to reach out.  

**Fred Lackey**  
[fred.lackey@gmail.com](mailto:fred.lackey@gmail.com)  
[https://fredlackey.com](https://fredlackey.com)
