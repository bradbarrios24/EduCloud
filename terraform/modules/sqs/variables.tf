variable "queue_name" {
  description = "Nombre de la cola SQS principal"
  type        = string
}

variable "dlq_name" {
  description = "Nombre de la Dead Letter Queue (mensajes fallidos)"
  type        = string
}

variable "max_receive_count" {
  description = "Numero maximo de reintentos antes de mover el mensaje a la DLQ (Tras N reintentos)"
  type        = number
  default     = 5
}

variable "message_retention_seconds" {
  description = "Tiempo de retencion de mensajes en la cola (segundos)"
  type        = number
  default     = 345600 # 4 dias
}

variable "visibility_timeout_seconds" {
  description = "Tiempo de visibilidad de la cola, coherente con el timeout de la Lambda"
  type        = number
  default     = 60
}

variable "api_gateway_role_arn" {
  description = "ARN del rol de API Gateway al que se le otorga permiso SendMessage. Si es null, no se crea la politica de acceso."
  type        = string
  default     = null
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