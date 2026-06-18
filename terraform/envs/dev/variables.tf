# ============================================
# VARIABLES DEL ENTORNO DEV - COMPLETO
# ============================================

# Variables base
variable "aws_region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Nombre del entorno"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  default     = "EduCloud"
}

# Variables S3
variable "bucket_name" {
  description = "Nombre del bucket S3 (vacío = generación automática)"
  type        = string
  default     = ""
}

# Variables WAF
variable "waf_rate_limit" {
  description = "Límite de requests por IP en 5 minutos"
  type        = number
  default     = 2000
}

# Variables Route53 (DNS)
variable "domain_name" {
  description = "Nombre del dominio (ej: educloud.com)"
  type        = string
  default     = ""
}

variable "subdomain" {
  description = "Subdominio (ej: app, api)"
  type        = string
  default     = "app"
}

variable "create_hosted_zone" {
  description = "Crear nuevo Hosted Zone en Route53"
  type        = bool
  default     = false
}

variable "create_www_record" {
  description = "Crear registro www.example.com"
  type        = bool
  default     = true
}

# Variables Cognito
variable "cognito_callback_urls" {
  description = "URLs permitidas después del login"
  type        = list(string)
  default     = ["http://localhost:3000", "https://app.educloud.com"]
}

variable "cognito_logout_urls" {
  description = "URLs permitidas después del logout"
  type        = list(string)
  default     = ["http://localhost:3000", "https://app.educloud.com"]
}

variable "cognito_default_redirect_uri" {
  description = "URL por defecto para redireccionamiento"
  type        = string
  default     = "http://localhost:3000"
}

variable "cognito_domain_prefix" {
  description = "Prefijo del dominio de Cognito"
  type        = string
  default     = ""
}

variable "create_identity_pool" {
  description = "Crear Identity Pool para federación"
  type        = bool
  default     = false
}

# ============================================
# VARIABLES PARA IAM ROLES
# ============================================

variable "create_api_user_roles" {
  description = "Crear roles IAM para usuarios autenticados"
  type        = bool
  default     = false
}

# ============================================
# ETIQUETAS COMUNES
# ============================================

locals {
  common_tags = {
    Environment = var.environment
    Proyecto    = var.project_name
    ManagedBy   = "Terraform"
  }
}