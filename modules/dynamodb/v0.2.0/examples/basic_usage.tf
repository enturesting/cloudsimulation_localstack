module "dynamodb" {
  source = "../../../"

  name        = "example-dynamodb"
  hash_key    = "id"
  billing_mode = "PAY_PER_REQUEST"
}
