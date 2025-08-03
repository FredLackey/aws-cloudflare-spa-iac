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