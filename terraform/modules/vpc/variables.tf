variable "vpc_cidr" {
  description = "Rango CIDR de la VPC principal"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Rango CIDR de la subred publica (aloja el NAT Gateway)"
  type        = string
  default     = "10.0.0.0/24"
}

variable "private_subnet_cidr" {
  description = "Rango CIDR de la subred privada (aloja la Lambda procesadora)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Zona de disponibilidad (AZ) a usar para las subredes"
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