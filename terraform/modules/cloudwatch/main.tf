# ============================================
# MÓDULO: Amazon CloudWatch (Monitoreo)
# Orquesta: Alarmas CW, Logs Insights, CW Dashboard, AWS X-Ray
# ============================================

module "alarms" {
  source = "./alarms"

  environment                       = var.environment
  sns_topic_arn                     = var.sns_topic_arn
  cloudfront_distribution_id        = var.cloudfront_distribution_id
  api_gateway_name                  = var.api_gateway_name
  api_gateway_stage                 = var.api_gateway_stage
  cloudfront_5xx_threshold          = var.cloudfront_5xx_threshold
  api_gateway_5xx_threshold         = var.api_gateway_5xx_threshold
  api_gateway_latency_threshold_ms  = var.api_gateway_latency_threshold_ms
  tags                              = var.tags
}

module "logs_insights" {
  source = "./logs_insights"

  environment         = var.environment
  log_retention_days  = var.log_retention_days
  tags                = var.tags
}

module "dashboard" {
  source = "./dashboard"

  environment                = var.environment
  dashboard_name              = var.dashboard_name
  aws_region                  = var.aws_region
  s3_bucket_name               = var.s3_bucket_name
  cloudfront_distribution_id  = var.cloudfront_distribution_id
  api_gateway_name             = var.api_gateway_name
  api_gateway_stage            = var.api_gateway_stage
}

module "xray" {
  source = "./xray"

  environment = var.environment
  tags        = var.tags
}