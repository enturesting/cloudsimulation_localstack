module "kms" {
  source = "../../../"

  name               = "example-kms-key"
  description        = "Example KMS key for encryption"
  enable_key_rotation = true
}
