# ============================================
# VARIABLES OBLIGATORIAS
# ============================================

variable "s3_bucket_domain_name" {
  description = "Nombre de dominio del bucket S3"
  type        = string
}

variable "s3_bucket_arn" {
  description = "ARN del bucket S3"
  type        = string
  default     = null  # ← opcional ahora
}

variable "s3_bucket_id" {
  description = "ID del bucket S3"
  type        = string
  default     = null  # ← opcional ahora
}

# ============================================
# VARIABLES CON VALORES POR DEFECTO
# ============================================

variable "enabled" {
  description = "Habilitar distribución CloudFront"
  type        = bool
  default     = true
}

variable "default_root_object" {
  description = "Archivo por defecto"
  type        = string
  default     = "index.html"
}

variable "origin_id" {
  description = "ID del origen"
  type        = string
  default     = "S3FrontendOrigin"
}

variable "allowed_methods" {
  description = "Métodos HTTP permitidos"
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "cached_methods" {
  description = "Métodos HTTP a cachear"
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "forward_query_string" {
  description = "Reenviar query strings"
  type        = bool
  default     = false
}

variable "cookie_forward" {
  description = "Reenviar cookies"
  type        = string
  default     = "none"
}

variable "viewer_protocol_policy" {
  description = "Política de protocolo HTTPS"
  type        = string
  default     = "redirect-to-https"
}

variable "min_ttl" {
  description = "TTL mínimo en segundos"
  type        = number
  default     = 0
}

variable "default_ttl" {
  description = "TTL por defecto en segundos"
  type        = number
  default     = 3600
}

variable "max_ttl" {
  description = "TTL máximo en segundos"
  type        = number
  default     = 86400
}

variable "geo_restriction_type" {
  description = "Tipo de restricción geográfica"
  type        = string
  default     = "none"
}

variable "use_default_certificate" {
  description = "No usar certificado por defecto de CloudFront"
  type        = bool
  default     = false
}

variable "acm_certificate_arn" {
  description = "ARN del certificado ACM para CloudFront"
  type        = string
  default     = null
}

variable "web_acl_id" {
  description = "ID del WAF asociado"
  type        = string
  default     = null
}

variable "enable_logging" {
  type    = bool
  default = false  # false en dev
}


variable "ssl_support_method" {
  description = "Método de soporte SSL"
  type        = string
  default     = "sni-only"
}

variable "minimum_protocol_version" {
  description = "Versión mínima de protocolo"
  type        = string
  default     = "TLSv1.2_2021"
}

variable "oai_comment" {
  description = "Comentario para OAI"
  type        = string
  default     = "Origin Access Identity for S3 bucket"
}

variable "create_s3_policy" {
  description = "Crear política para S3"
  type        = bool
  default     = true
}

variable "log_bucket_name" {
  description = "Nombre del bucket para logs de CloudFront"
  type        = string
  default     = ""
}

variable "geo_allowed_locations" {
  description = "Lista de países permitidos"
  type        = list(string)
  default     = ["PE"]
}

variable "tags" {
  description = "Etiquetas para CloudFront"
  type        = map(string)
  default     = {}
}