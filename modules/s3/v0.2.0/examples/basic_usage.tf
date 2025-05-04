module "s3" {
  source = "../../../"

  name        = "example-s3-bucket"
  versioning  = true
}
