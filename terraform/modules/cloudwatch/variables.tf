variable "environment" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "dashboard_name" {
  type    = string
  default = "EduCloud-Monitoring"
}

variable "sns_topic_arn" {
  description = "ARN del tópico SNS (creado fuera de modules/, ej: module.sns.topic_arn)"
  type        = string
}

variable "s3_bucket_name" {
  type = string
}

variable "cloudfront_distribution_id" {
  type = string
}

variable "api_gateway_name" {
  type = string
}

variable "api_gateway_stage" {
  type = string
}

variable "cloudfront_5xx_threshold" {
  type    = number
  default = 5
}

variable "api_gateway_5xx_threshold" {
  type    = number
  default = 5
}

variable "api_gateway_latency_threshold_ms" {
  type    = number
  default = 3000
}

variable "log_retention_days" {
  type    = number
  default = 14
}

variable "tags" {
  type    = map(string)
  default = {}
}