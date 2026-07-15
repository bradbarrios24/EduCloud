output "bucket_arn" {
  description = "ARN del bucket de uploads"
  value       = aws_s3_bucket.this.arn
}

output "bucket_id" {
  description = "ID/nombre del bucket de uploads"
  value       = aws_s3_bucket.this.id
}

output "bucket_domain_name" {
  description = "Nombre de dominio regional del bucket"
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}