variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  description = "Subnet PÚBLICA (la tarea necesita IP pública, no hay NAT/ALB delante)"
  type        = string
}

variable "cluster_id" {
  type = string
}

variable "execution_role_arn" {
  type = string
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "allowed_cidr_blocks" {
  description = "IPs permitidas para acceder a Grafana (pon tu IP pública /32, NO dejes 0.0.0.0/0)"
  type        = list(string)
}

variable "admin_user" {
  type    = string
  default = "admin"
}

variable "admin_password" {
  description = "Password del admin de Grafana — pásalo por variable, no lo hardcodees en el repo"
  type        = string
  sensitive   = true
}

variable "tags" {
  type    = map(string)
  default = {}
}