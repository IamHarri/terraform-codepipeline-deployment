terraform {
  backend "s3" {
    bucket         = "training-terraspace-long-us-east-1-dev-state"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}
