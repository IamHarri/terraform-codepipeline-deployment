module "s3-website-www" {
  source                  = "terraform-aws-modules/s3-bucket/aws"
  version                 = "4.1.2"
  force_destroy           = true
  bucket                  = var.static_website_bucket_name
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
  website = {
    index_document = "index.html"
    error_document = "error.html"
  }
  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"

  versioning = {
    enabled = true
  }
}

