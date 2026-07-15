variable "topic_name" {
  description = "Nombre del tópico SNS"
  type        = string
}

variable "alarm_email" {
  description = "Email para suscripción. Vacío = no crear suscripción"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Etiquetas para los recursos"
  type        = map(string)
  default     = {}
}