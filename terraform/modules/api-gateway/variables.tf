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

variable "log_group_arn" {
  type    = string
  default = null
}

variable "xray_tracing_enabled" {
  type    = bool
  default = false
}

variable "sqs_queue_arn" {
  description = "ARN de la cola SQS principal. Se usa para la política IAM del rol de integración y para derivar la URI de integración hacia SQS (region, account id y nombre de cola se extraen del propio ARN)."
  type        = string
}

variable "mensajes_requires_cognito_auth" {
  description = "Si es true, POST /api/mensajes reutiliza el Cognito Authorizer existente. Si es false, el endpoint queda abierto (NONE)."
  type        = bool
  default     = true
}