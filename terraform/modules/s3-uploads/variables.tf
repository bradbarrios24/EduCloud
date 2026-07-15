variable "bucket_prefix" {
  description = "Prefijo del nombre del bucket (se le agrega environment + sufijo random)"
  type        = string
  default     = "educloud-uploads"
}

variable "environment" {
  description = "Nombre del entorno (dev, staging, prod)"
  type        = string
}

variable "versioning_enabled" {
  description = "Habilitar versionado del bucket"
  type        = bool
  default     = true
}

variable "cors_allowed_origins" {
  description = "Orígenes permitidos para CORS (ej: URL de CloudFront del frontend). Vacío = sin CORS configurado."
  type        = list(string)
  default     = []
}

variable "enable_lifecycle" {
  description = "Habilitar regla de transición a Standard-IA"
  type        = bool
  default     = false
}

variable "transition_to_ia_days" {
  description = "Días antes de mover objetos a Standard-IA"
  type        = number
  default     = 90
}

variable "tags" {
  description = "Etiquetas para los recursos"
  type        = map(string)
  default     = {}
}