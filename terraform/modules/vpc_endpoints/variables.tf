variable "vpc_id" {
  description = "ID de la VPC donde se creara el endpoint"
  type        = string
}

variable "private_subnet_id" {
  description = "ID de la subred privada donde residira el endpoint"
  type        = string
}

variable "security_group_id" {
  description = "ID del Security Group permitido a usar el endpoint (SG de la Lambda)"
  type        = string
}

variable "region" {
  description = "Region de AWS donde se despliega el endpoint (ej. us-east-1)"
  type        = string
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