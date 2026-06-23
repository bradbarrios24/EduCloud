# ============================================
# MÓDULO: S3 para Frontend
# ============================================

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name != null ? var.bucket_name : "frontend-${random_id.suffix[0].hex}"  # ← agregar [0]
  
  tags = var.tags
}

resource "random_id" "suffix" {
  count       = var.bucket_name == null ? 1 : 0
  byte_length = 4
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id
  
  rule {
    id     = "TransitionToInfrequentAccess"
    status = "Enabled"
    
    filter {}   # ← aplica a todos los objetos
    
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
  
  rule {
    id     = "ExpireOldVersions"
    status = "Enabled"
    
    filter {}   # ← también aquí
    
    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  count  = var.cloudfront_distribution_arn != null ? 1 : 0
  bucket = aws_s3_bucket.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.this.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = var.cloudfront_distribution_arn
          }
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.this]
}