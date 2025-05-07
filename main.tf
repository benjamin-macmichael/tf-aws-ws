terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.0.0"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "bgm-terraf0rm-s3-website-20250507"
}

resource "aws_s3_bucket_ownership_controls" "my_bucket_ownership_controls" {
  bucket = aws_s3_bucket.my_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_website_configuration" "my_bucket_website" {
  bucket = aws_s3_bucket.my_bucket.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "my_bucket_public_access_block" {
  bucket = aws_s3_bucket.my_bucket.id

  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = false
  restrict_public_buckets = false
}

resource "aws_s3_object" "index_html" {
  bucket = aws_s3_bucket.my_bucket.bucket
  key    = "index.html"
  source = "index.html"
  acl    = "public-read"
  content_type = "text/html"

  depends_on = [
    aws_s3_bucket_public_access_block.my_bucket_public_access_block,
    aws_s3_bucket_ownership_controls.my_bucket_ownership_controls,
  ]
}

resource "aws_s3_object" "style_css" {
  bucket = aws_s3_bucket.my_bucket.bucket
  key    = "style.css"
  source = "style.css"
  acl    = "public-read"
  content_type = "text/css"

  depends_on = [
    aws_s3_bucket_public_access_block.my_bucket_public_access_block,
    aws_s3_bucket_ownership_controls.my_bucket_ownership_controls,
  ]
}

resource "aws_s3_bucket_policy" "my_bucket_policy" {
  bucket = aws_s3_bucket.my_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.my_bucket.arn}/*"
      },
    ]
  })

  depends_on = [
    aws_s3_bucket_public_access_block.my_bucket_public_access_block,
    aws_s3_bucket_ownership_controls.my_bucket_ownership_controls,
  ]
}

output "website_url" {
  value = aws_s3_bucket_website_configuration.my_bucket_website.website_domain
  description = "The URL of the S3 website endpoint"
}