# ============================================
# VARIABLES DEL MÓDULO S3-FRONTEND
# ============================================

variable "bucket_name" {
  description = "Nombre del bucket S3 (null = generación automática)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Etiquetas para el bucket"
  type        = map(string)
  default     = {}
}

variable "cloudfront_distribution_arn" {
  description = "ARN de la distribución CloudFront para la bucket policy"
  type        = string
  default     = null
}
