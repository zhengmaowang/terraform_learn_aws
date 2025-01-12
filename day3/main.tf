provider "aws" {
  region = "ap-southeast-2"
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = "terraform-aws-state-sandbox"
  versioning_configuration {
    status = "Enabled"
  }
  lifecycle {
    prevent_destroy = true
  }

}

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = "terraform-aws-state-sandbox"

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

terraform {
  backend "s3" {
    bucket =  "terraform-aws-state-sandbox"
    key = "global/s3/terraform.tfstate"
    region = "ap-southeast-2"

    dynamodb_table = "terraform-aws-locks"
    encrypt = true
  }
}

