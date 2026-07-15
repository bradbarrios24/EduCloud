variable "domain" {
  description = "Dominio a verificar en SES como remitente (mutuamente excluyente con 'email')"
  type        = string
  default     = null
}

variable "email" {
  description = "Direccion de correo especifica a verificar en SES como remitente (mutuamente excluyente con 'domain')"
  type        = string
  default     = null
}

variable "enable_configuration_set" {
  description = "Si se habilita un Configuration Set de SES para tracking de entregas/rebotes"
  type        = bool
  default     = false
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