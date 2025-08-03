# PLACEHOLDER VALUES - Replace with your actual configuration
# Environment configuration
environment = "sbx"

# Lambda function name from DevOps team (iac-env-hosting output)
# Get this value after running iac-env-hosting: terraform output lambda_function_name
function_name = "yourapp-api-sbx"  # Replace yourapp with your application name

# Path to your application's zip file
# Replace with your actual API project path
lambda_source_path = "../../apps/mock-real-api/lambda-deployment.zip"

# Optional environment variables updates
# Leave empty {} to keep existing environment variables
environment_variables = {}