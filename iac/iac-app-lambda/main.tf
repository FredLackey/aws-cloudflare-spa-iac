# Data source to reference existing Lambda function created by DevOps
# This is READ-ONLY - we never modify the function resource itself
data "aws_lambda_function" "existing" {
  function_name = var.function_name
}

# Update Lambda code only - no resource management
resource "null_resource" "update_code" {
  triggers = {
    code_hash = filebase64sha256(var.lambda_source_path)
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Updating Lambda function code: ${var.function_name}"
      aws lambda update-function-code \
        --function-name ${var.function_name} \
        --zip-file fileb://${var.lambda_source_path} \
        --profile your-aws-profile-name
      
      ${length(var.environment_variables) > 0 ? 
        "aws lambda update-function-configuration --function-name ${var.function_name} --environment Variables='${jsonencode(var.environment_variables)}' --profile bh-fred-sandbox" : 
        "echo 'No environment variables to update'"}
    EOT
  }
}