# S3 Cloud Storage Bucket for Application Assets and State
resource "aws_s3_bucket" "app_storage" {
  bucket        = var.bucket_name
  force_destroy = true

  tags = {
    Name    = var.bucket_name
    Purpose = "Application Assets and Logging Storage"
    Tier    = "Storage"
  }
}

# S3 Versioning Configuration
resource "aws_s3_bucket_versioning" "app_versioning" {
  bucket = aws_s3_bucket.app_storage.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

# S3 Server-Side Encryption Configuration (SSE-S3 AES-256)
resource "aws_s3_bucket_server_side_encryption_configuration" "app_encryption" {
  bucket = aws_s3_bucket.app_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# S3 Public Access Block Configuration
resource "aws_s3_bucket_public_access_block" "app_pab" {
  bucket = aws_s3_bucket.app_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
