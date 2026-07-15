variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
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
  type = list(string)
}

variable "db_password" {
  description = "Password de Postgres para SonarQube — pásalo por variable, nunca lo hardcodees"
  type        = string
  sensitive   = true
}

variable "tags" {
  type    = map(string)
  default = {}
}