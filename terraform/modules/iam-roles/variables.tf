# ============================================
# VARIABLES DEL MÓDULO IAM ROLES
# ============================================

variable "environment" {
  description = "Nombre del entorno (dev, staging, prod)"
  type        = string
  default     = "dev"
}

# Variables para CodePipeline
variable "create_codepipeline_role" {
  description = "Crear rol para CodePipeline"
  type        = bool
  default     = false
}

variable "artifact_bucket_arn" {
  description = "ARN del bucket de artefactos"
  type        = string
  default     = null
}

# Variables para CodeBuild
variable "create_codebuild_role" {
  description = "Crear rol para CodeBuild"
  type        = bool
  default     = false
}

# Variables para Terraform
variable "create_terraform_role" {
  description = "Crear rol para Terraform"
  type        = bool
  default     = false
}

variable "terraform_user_arns" {
  description = "ARNs de usuarios que pueden asumir el rol de Terraform"
  type        = list(string)
  default     = []
}

# Variables para API Users
variable "create_api_user_role" {
  description = "Crear rol para usuarios autenticados de API"
  type        = bool
  default     = false
}

variable "cognito_identity_pool_id" {
  description = "ID del Identity Pool de Cognito"
  type        = string
  default     = ""
}

variable "cognito_username_key" {
  description = "Key para el username en Cognito"
  type        = string
  default     = "cognito:username"
}

variable "api_gateway_arn" {
  description = "ARN del API Gateway"
  type        = string
  default     = ""
}

variable "s3_bucket_arn" {
  description = "ARN del bucket S3"
  type        = string
  default     = ""
}

# Etiquetas comunes
variable "tags" {
  description = "Etiquetas para todos los recursos"
  type        = map(string)
  default     = {}
}

variable "create_role_based_access" {
  description = "Crear roles admin/docente/estudiante"
  type        = bool
  default     = true
}

variable "api_gateway_execution_arn" {
  description = "Execution ARN del stage de API Gateway (ej: arn:aws:execute-api:us-east-1:123456789012:abc123/prod)"
  type        = string
  default     = ""

  validation {
    condition     = !var.create_role_based_access || can(regex("^arn:aws:execute-api:", var.api_gateway_execution_arn))
    error_message = "api_gateway_execution_arn debe ser un execution ARN válido cuando create_role_based_access = true. Verifica que estás pasando module.api_gateway.execution_arn en envs/dev/main.tf."
  }
}

variable "uploads_bucket_arn" {
  description = "ARN del bucket S3 de archivos/uploads"
  type        = string
  default     = ""
}