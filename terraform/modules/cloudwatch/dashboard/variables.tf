variable "environment" {
  type = string
}

variable "dashboard_name" {
  type    = string
  default = "EduCloud-Monitoring"
}

variable "aws_region" {
  type = string
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