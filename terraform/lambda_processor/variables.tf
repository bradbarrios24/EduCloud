variable "function_name" {
  description = "Nombre de la funcion Lambda procesadora"
  type        = string
}

variable "runtime" {
  description = "Runtime de la Lambda (ej. python3.12, nodejs20.x)"
  type        = string
  default     = "python3.12"
}

variable "handler" {
  description = "Handler de entrada de la Lambda (ej. app.handler)"
  type        = string
  default     = "app.handler"
}

variable "memory_size" {
  description = "Memoria asignada a la Lambda en MB"
  type        = number
  default     = 256
}

variable "timeout" {
  description = "Timeout de la Lambda en segundos"
  type        = number
  default     = 30
}

variable "lambda_zip_path" {
  description = "Ruta local a un .zip pre-generado con el codigo de la Lambda. Si es null, Terraform empaqueta automaticamente la carpeta src/ usando archive_file."
  type        = string
  default     = null
}

variable "sqs_queue_arn" {
  description = "ARN de la cola SQS que dispara la Lambda"
  type        = string
}

variable "private_subnet_id" {
  description = "ID de la subred privada donde se despliega la Lambda"
  type        = string
}

variable "security_group_id" {
  description = "ID del Security Group asociado a la Lambda"
  type        = string
}

variable "environment_variables" {
  description = "Variables de entorno que necesita la Lambda (ej. remitente de SES)"
  type        = map(string)
  default     = {}
}

variable "batch_size" {
  description = "Tamano de lote (batch size) de mensajes SQS por invocacion"
  type        = number
  default     = 10
}

variable "environment" {
  description = "Nombre del entorno (dev/prod)"
  type        = string
}

variable "tags" {
  description = "Etiquetas comunes a aplicar a todos los recursos"
  type        = map(string)
  default     = {}
}