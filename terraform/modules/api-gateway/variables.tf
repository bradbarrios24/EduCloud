variable "api_name" {
  description = "Nombre del API Gateway"
  type        = string
  default     = "educloud-api"
}

variable "api_description" {
  description = "Descripción del API Gateway"
  type        = string
  default     = "API REST de EduCloud"
}

variable "stage_name" {
  description = "Nombre del stage (dev, prod)"
  type        = string
  default     = "dev"
}

variable "cognito_user_pool_arn" {
  description = "ARN del User Pool de Cognito para el authorizer"
  type        = string
}

variable "tags" {
  description = "Etiquetas para los recursos"
  type        = map(string)
  default     = {}
}