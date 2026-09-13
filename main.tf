terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.64.0"
    }
     random = {
      source  = "hashicorp/random"
      version = "3.9.1"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_s3_bucket" "demo1" {
  bucket = "abc${random_id.name.hex}"
}

resource "random_id" "name" {
   byte_length = 8
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.demo1.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "mywebapp" {
  bucket = aws_s3_bucket.demo1.bucket
  policy = jsonencode(
    {
    Version= "2012-10-17",
    Statement= [
        {
            Sid= "PublicReadGetObject",
            Effect= "Allow",
            Principal= "*",
            Action= "s3:GetObject",
            Resource= "arn:aws:s3:::${aws_s3_bucket.demo1.id}/*"
        }
    ]
}
  )
}

resource "aws_s3_bucket_website_configuration" "mywebstatic" {
  bucket = aws_s3_bucket.demo1.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_object" "indexhtml" {
  bucket = aws_s3_bucket.demo1.bucket
  source = "./index.html"
  key = "index.html"
  content_type = "text/html"
}
resource "aws_s3_object" "stylecss" {
  bucket = aws_s3_bucket.demo1.bucket
  source = "./style.css"
  key = "style.css"
  content_type = "text/css"
}

output "url" {
  value = aws_s3_bucket_website_configuration.mywebstatic.website_endpoint
}