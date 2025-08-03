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

variable "environment" {
  description = "Environment name (e.g., sbx, dev, prod)"
  type        = string
  default     = "sbx"
}