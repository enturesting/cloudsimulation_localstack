module "lambda" {
  source = "../../../"

  name        = "example-lambda"
  description = "Example Lambda function"
  runtime     = "python3.9"
  handler     = "lambda_function.lambda_handler"

  environment = {
    variables = {
      ENV = "dev"
    }
  }
}
