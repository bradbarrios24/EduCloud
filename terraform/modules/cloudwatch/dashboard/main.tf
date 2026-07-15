# ============================================
# SUBMÓDULO: CW Dashboard (Visualización Unificada)
# ============================================

resource "aws_cloudwatch_dashboard" "this" {
  dashboard_name = "${var.dashboard_name}-${var.environment}"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "text", x = 0, y = 0, width = 24, height = 1
        properties = {
          markdown = "# EduCloud - Monitoreo (${var.environment})\nS3 privado · CloudFront (CDN) · API Gateway"
        }
      },
      {
        type = "metric", x = 0, y = 1, width = 12, height = 6
        properties = {
          title  = "CloudFront - Solicitudes"
          view   = "timeSeries"
          region = "us-east-1"
          metrics = [
            ["AWS/CloudFront", "Requests", "DistributionId", var.cloudfront_distribution_id, "Region", "Global", { stat = "Sum" }]
          ]
          period = 300
        }
      },
      {
        type = "metric", x = 12, y = 1, width = 12, height = 6
        properties = {
          title  = "CloudFront - Bytes Transferidos"
          view   = "timeSeries"
          region = "us-east-1"
          metrics = [
            ["AWS/CloudFront", "BytesDownloaded", "DistributionId", var.cloudfront_distribution_id, "Region", "Global", { stat = "Sum" }]
          ]
          period = 300
        }
      },
      {
        type = "metric", x = 0, y = 7, width = 12, height = 6
        properties = {
          title  = "CloudFront - Tasa de Errores (%)"
          view   = "timeSeries"
          region = "us-east-1"
          metrics = [
            ["AWS/CloudFront", "4xxErrorRate", "DistributionId", var.cloudfront_distribution_id, "Region", "Global", { stat = "Average", color = "#ff9896" }],
            ["AWS/CloudFront", "5xxErrorRate", "DistributionId", var.cloudfront_distribution_id, "Region", "Global", { stat = "Average", color = "#d62728" }]
          ]
          period = 300
        }
      },
      {
        type = "metric", x = 12, y = 7, width = 12, height = 6
        properties = {
          title  = "S3 - Tamaño del Bucket (bytes)"
          view   = "timeSeries"
          region = var.aws_region
          metrics = [
            ["AWS/S3", "BucketSizeBytes", "BucketName", var.s3_bucket_name, "StorageType", "StandardStorage", { stat = "Average" }]
          ]
          period = 86400
        }
      },
      {
        type = "metric", x = 0, y = 13, width = 12, height = 6
        properties = {
          title  = "S3 - Número de Objetos"
          view   = "timeSeries"
          region = var.aws_region
          metrics = [
            ["AWS/S3", "NumberOfObjects", "BucketName", var.s3_bucket_name, "StorageType", "AllStorageTypes", { stat = "Average" }]
          ]
          period = 86400
        }
      },
      {
        type = "metric", x = 12, y = 13, width = 12, height = 6
        properties = {
          title  = "API Gateway - Solicitudes"
          view   = "timeSeries"
          region = var.aws_region
          metrics = [
            ["AWS/ApiGateway", "Count", "ApiName", var.api_gateway_name, "Stage", var.api_gateway_stage, { stat = "Sum" }]
          ]
          period = 300
        }
      },
      {
        type = "metric", x = 0, y = 19, width = 12, height = 6
        properties = {
          title  = "API Gateway - Errores"
          view   = "timeSeries"
          region = var.aws_region
          metrics = [
            ["AWS/ApiGateway", "4XXError", "ApiName", var.api_gateway_name, "Stage", var.api_gateway_stage, { stat = "Sum", color = "#ff9896" }],
            ["AWS/ApiGateway", "5XXError", "ApiName", var.api_gateway_name, "Stage", var.api_gateway_stage, { stat = "Sum", color = "#d62728" }]
          ]
          period = 300
        }
      },
      {
        type = "metric", x = 12, y = 19, width = 12, height = 6
        properties = {
          title  = "API Gateway - Latencia (ms)"
          view   = "timeSeries"
          region = var.aws_region
          metrics = [
            ["AWS/ApiGateway", "Latency", "ApiName", var.api_gateway_name, "Stage", var.api_gateway_stage, { stat = "Average" }],
            ["AWS/ApiGateway", "IntegrationLatency", "ApiName", var.api_gateway_name, "Stage", var.api_gateway_stage, { stat = "Average" }]
          ]
          period = 300
        }
      }
    ]
  })
}