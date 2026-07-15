variable "environment" {
  type = string
}

variable "sns_topic_arn" {
  description = "ARN del tópico SNS al que se enviarán las alarmas"
  type        = string
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

variable "tags" {
  type    = map(string)
  default = {}
}