variable "cluster_name" {
  description = "Nombre del clúster ECS"
  type        = string
}

variable "use_spot" {
  description = "Usar FARGATE_SPOT (más barato, puede interrumpirse — bien para demo, mal para prod)"
  type        = bool
  default     = true
}

variable "container_insights_enabled" {
  description = "Habilitar CloudWatch Container Insights (genera costo extra de métricas)"
  type        = bool
  default     = false
}

variable "tags" {
  type    = map(string)
  default = {}
}