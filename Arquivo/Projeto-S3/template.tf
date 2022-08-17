# PROVIDER
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# REGION
provider "aws" {
    region = "us-east-1"
    shared_credentials_file = ".aws/credentials"
}
#S3 bucket
resource "aws_s3_bucket" "S3-alberty-c4" {
  bucket = "fiap-cloud-vds-aws-s3-alberty"
}
resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.S3-alberty-c4.id
  policy = data.aws_iam_policy_document.allow_access_from_another_account.json
}

data "aws_iam_policy_document" "allow_access_from_another_account" {
  statement {
     principals {
      type        = "AWS"
      identifiers = [""]
    }
    
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      
    ]

    resources = [
      aws_s3_bucket.S3-alberty-c4.arn,
      "${aws_s3_bucket.S3-alberty-c4.arn}/*",
    ]
  }
}
#S3 acl
resource "aws_s3_bucket_acl" "S3-alberty-acl" {
  bucket = aws_s3_bucket.S3-alberty-c4.id
  acl    = "public-read"
}
#Versioning
resource "aws_s3_bucket_versioning" "version" {
  bucket = aws_s3_bucket.S3-alberty-c4.id
versioning_configuration {
    status = "Enabled"
    
  }
}
#S3 website config
resource "aws_s3_bucket_website_configuration" "website-config" {
  bucket = aws_s3_bucket.S3-alberty-c4.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  routing_rule {
    condition {
      key_prefix_equals = "doc-html/"
    }
    redirect {
      replace_key_prefix_with = "doc-error/"
    }
  }
}

