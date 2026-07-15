variable "environment" {
  description = "Nombre del ambiente (dev, prod, etc.)"
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC donde correrá Jenkins"
  type        = string
}

variable "subnet_id" {
  description = "Subnet pública donde se despliega la tarea"
  type        = string
}

variable "cluster_id" {
  description = "ID del clúster ECS (del módulo ecs-cluster genérico)"
  type        = string
}

variable "execution_role_arn" {
  description = "ARN del execution role compartido (del módulo ecs-cluster genérico)"
  type        = string
}

variable "allowed_cidr_blocks" {
  description = "CIDRs permitidos para acceder a Jenkins (UI y agente)"
  type        = list(string)
}

variable "aws_region" {
  description = "Región de AWS para los logs de CloudWatch"
  type        = string
}

variable "skip_setup_wizard" {
  description = "Si es true, salta el wizard inicial de setup de Jenkins (útil para demo rápida, pero entonces necesitas configurar admin vía Configuration as Code aparte)"
  type        = bool
  default     = false
}

variable "tags" {
  type    = map(string)
  default = {}
}