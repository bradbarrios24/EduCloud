# ============================================
# VARIABLES DEL MÓDULO WAF
# ============================================

variable "waf_name" {
  description = "Nombre del Web ACL"
  type        = string
  default     = "educloud-waf"
}

variable "waf_description" {
  description = "Descripción del Web ACL"
  type        = string
  default     = "WAF para proteger CloudFront de EduCloud"
}

variable "rate_limit" {
  description = "Límite de requests por IP en 5 minutos"
  type        = number
  default     = 2000
}

variable "cloudfront_distribution_arn" {
  description = "ARN de la distribución CloudFront para asociar WAF"
  type        = string
  default     = null
}

variable "tags" {
  description = "Etiquetas para WAF"
  type        = map(string)
  default     = {}
}