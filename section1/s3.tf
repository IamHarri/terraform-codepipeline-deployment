module "s3-website-www" {
  source                  = "terraform-aws-modules/s3-bucket/aws"
  version                 = "4.1.2"
  force_destroy           = true
  bucket                  = "my-website-demo-codepipeline"
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

# resource "aws_s3_bucket_policy" "s3-website-www" {
#   bucket     = module.s3-website-www.s3_bucket_id
#   policy     = data.aws_iam_policy_document.bucket_policy.json
#   depends_on = [module.s3-website-www]
# }


resource "aws_s3_bucket_object" "object" {
  bucket = module.s3-website-www.s3_bucket_id
  key    = "my-website.zip"
  source = "./app/my-website.zip"
  etag   = filemd5("./app/my-website.zip")
}
