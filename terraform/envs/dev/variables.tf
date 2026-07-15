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

variable "alarm_email" {
  description = "Email para recibir notificaciones de alarmas de CloudWatch"
  type        = string
  default     = ""
}

# ============================================
# VARIABLES PARA VPC (pipeline de mensajeria)
# ============================================

variable "vpc_cidr" {
  description = "Rango CIDR de la VPC del pipeline de mensajeria"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Rango CIDR de la subred publica (NAT Gateway)"
  type        = string
  default     = "10.0.0.0/24"
}

variable "private_subnet_cidr" {
  description = "Rango CIDR de la subred privada (Lambda procesadora)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Zona de disponibilidad (AZ) para las subredes"
  type        = string
  default     = "us-east-1a"
}

# ============================================
# VARIABLES PARA SQS + DLQ
# ============================================

variable "sqs_queue_name" {
  description = "Nombre de la cola SQS principal"
  type        = string
  default     = "educloud-mensajes-dev"
}

variable "sqs_dlq_name" {
  description = "Nombre de la Dead Letter Queue"
  type        = string
  default     = "educloud-mensajes-dlq-dev"
}

variable "sqs_max_receive_count" {
  description = "Numero de reintentos antes de mover el mensaje a la DLQ"
  type        = number
  default     = 5
}

variable "sqs_message_retention_seconds" {
  description = "Tiempo de retencion de mensajes en la cola (segundos)"
  type        = number
  default     = 345600 # 4 dias
}

variable "sqs_visibility_timeout_seconds" {
  description = "Tiempo de visibilidad de la cola (segundos)"
  type        = number
  default     = 60
}

# ============================================
# VARIABLES PARA SES
# ============================================

variable "ses_domain" {
  description = "Dominio a verificar en SES (vacio si usas email individual)"
  type        = string
  default     = ""
}

variable "ses_email" {
  description = "Email a verificar en SES (vacio si usas dominio completo)"
  type        = string
  default     = ""
}

variable "ses_enable_configuration_set" {
  description = "Habilitar Configuration Set de SES para tracking de entregas/rebotes"
  type        = bool
  default     = false
}

# ============================================
# VARIABLES PARA LAMBDA PROCESSOR
# ============================================

variable "lambda_processor_function_name" {
  description = "Nombre de la funcion Lambda procesadora"
  type        = string
  default     = "educloud-lambda-processor-dev"
}

variable "lambda_processor_runtime" {
  description = "Runtime de la Lambda procesadora"
  type        = string
  default     = "python3.12"
}

variable "lambda_processor_handler" {
  description = "Handler de la Lambda procesadora"
  type        = string
  default     = "app.handler"
}

variable "lambda_processor_memory_size" {
  description = "Memoria de la Lambda procesadora (MB)"
  type        = number
  default     = 256
}

variable "lambda_processor_timeout" {
  description = "Timeout de la Lambda procesadora (segundos)"
  type        = number
  default     = 30
}

variable "lambda_processor_batch_size" {
  description = "Tamano de lote de mensajes SQS por invocacion"
  type        = number
  default     = 10
}

variable "lambda_processor_zip_path" {
  description = "Ruta a un .zip pre-generado (opcional). Si se deja null, Terraform empaqueta automaticamente src/ del modulo lambda_processor."
  type        = string
  default     = null
}

variable "lambda_processor_environment_variables" {
  description = "Variables de entorno adicionales para la Lambda procesadora"
  type        = map(string)
  default     = {}
}

# ============================================
# VARIABLES PARA VPC ENDPOINTS
# ============================================

variable "enable_vpc_endpoints" {
  description = "Habilitar VPC Endpoint de SES para no depender del NAT Gateway"
  type        = bool
  default     = false
}

variable "grafana_admin_password" {
  type      = string
  sensitive = true
}

variable "sonarqube_db_password" {
  type      = string
  sensitive = true
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