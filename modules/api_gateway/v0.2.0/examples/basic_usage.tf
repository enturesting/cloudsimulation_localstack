module "api_gateway" {
  source = "../../../"

  name        = "example-api"
  description = "Example API Gateway"
  stage_name  = "dev"

  routes = {
    "GET /" = "example-lambda"
  }
}
