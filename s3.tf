resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
}

#resource "aws_kms_key" "s3key" {
#  description             = "This key is used to encrypt bucket objects"
#  deletion_window_in_days = 10
#}

resource "aws_s3_bucket_server_side_encryption_configuration" "encrypt-bucket" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
#      sse_algorithm     = "aws:kms"
      sse_algorithm     = "AES256"
    }
  }
}

import {
  to = aws_s3_bucket_server_side_encryption_configuration.encrypt-bucket
  id = var.bucket_name
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "PublicReadGetObject",
          "Effect" : "Allow",
          "Principal" : "*",
          "Action" : "s3:GetObject",
          "Resource" : "arn:aws:s3:::${aws_s3_bucket.bucket.id}/*"
        }
      ]
    }
  )
}

resource "aws_s3_object" "file" {
  bucket       = aws_s3_bucket.bucket.id
  key          = "index.html"
  content_type = "text/html"
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "hosting" {
  bucket = aws_s3_bucket.bucket.id

  index_document {
    suffix = "index.html"
  }
}
