# ============================================
# SUBMÓDULO: Logs Insights (Análisis de logs SQL)
# ============================================

resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/educloud-${var.environment}"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

# Consulta guardada: errores 5xx recientes
resource "aws_cloudwatch_query_definition" "api_errors" {
  name            = "EduCloud-${var.environment}-API-Errors"
  log_group_names = [aws_cloudwatch_log_group.api_gateway.name]

  query_string = <<-EOT
    fields @timestamp, @message
    | filter status >= 500
    | sort @timestamp desc
    | limit 50
  EOT
}

# Consulta guardada: latencia por endpoint
resource "aws_cloudwatch_query_definition" "api_latency" {
  name            = "EduCloud-${var.environment}-API-Latency"
  log_group_names = [aws_cloudwatch_log_group.api_gateway.name]

  query_string = <<-EOT
    fields @timestamp, path, responseLatency
    | sort responseLatency desc
    | limit 50
  EOT
}