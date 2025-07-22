# Example: S3 Static Website with CloudFront-like setup
# This example shows how to use the S3 module for hosting a static website

module "website_bucket" {
  source = "../"
  
  environment_name = "prod"
  bucket_name     = "my-company-website"
  
  # Website configuration
  enable_website = true
  index_document = "index.html"
  error_document = "error.html"
  
  # Enable versioning for rollback capability
  enable_versioning = true
  
  # Public read access for website content
  bucket_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "arn:aws:s3:::my-company-website/*"
      }
    ]
  })
  
  tags = {
    Environment = "production"
    Purpose     = "static-website"
    Team        = "frontend"
  }
}

# Example of uploading website files
resource "aws_s3_object" "index" {
  bucket       = module.website_bucket.bucket_name
  key          = "index.html"
  source       = "website/index.html"
  content_type = "text/html"
  etag         = filemd5("website/index.html")
}

resource "aws_s3_object" "error" {
  bucket       = module.website_bucket.bucket_name
  key          = "error.html"
  source       = "website/error.html"
  content_type = "text/html"
  etag         = filemd5("website/error.html")
}

# Output the website URL
output "website_url" {
  description = "URL of the static website"
  value       = module.website_bucket.website_endpoint
}