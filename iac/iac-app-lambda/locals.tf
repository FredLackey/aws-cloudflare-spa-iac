locals {
  # Generate outputs.json content
  outputs_json = {
    package_name = "iac-app-lambda"
    environment  = var.environment
    timestamp    = timestamp()
    resources_updated = {
      lambda_functions = [
        {
          name          = data.aws_lambda_function.existing.function_name
          arn           = data.aws_lambda_function.existing.arn
          last_modified = data.aws_lambda_function.existing.last_modified
          code_updated  = true
        }
      ]
    }
    terraform_outputs = {
      function_name = data.aws_lambda_function.existing.function_name
      function_arn  = data.aws_lambda_function.existing.arn
    }
  }
}

# Generate outputs.json file
resource "local_file" "outputs_json" {
  content  = jsonencode(local.outputs_json)
  filename = "${path.module}/outputs.json"

  depends_on = [
    null_resource.update_code
  ]
}