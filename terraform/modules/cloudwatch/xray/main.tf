# ============================================
# SUBMÓDULO: AWS X-Ray (Trazas de extremo a extremo)
# ============================================

resource "aws_xray_sampling_rule" "this" {
  rule_name      = "educloud-${var.environment}"
  priority       = 1000
  version        = 1
  reservoir_size = 1
  fixed_rate     = 0.1
  url_path       = "*"
  host           = "*"
  http_method    = "*"
  service_type   = "*"
  service_name   = "*"
  resource_arn   = "*"

  tags = var.tags
}