# ============================================
# MÓDULO: Route53 (DNS)
# ============================================

# 1. OBTENER EL HOSTED ZONE EXISTENTE (o crearlo)
data "aws_route53_zone" "this" {
  count = var.create_hosted_zone ? 0 : 1
  name  = var.domain_name
}

resource "aws_route53_zone" "this" {
  count = var.create_hosted_zone ? 1 : 0
  name  = var.domain_name
  
  tags = var.tags
}

locals {
  zone_id = var.create_hosted_zone ? aws_route53_zone.this[0].zone_id : data.aws_route53_zone.this[0].zone_id
}

# 2. CREAR REGISTRO A (Alias a CloudFront)
resource "aws_route53_record" "frontend" {
  count = var.cloudfront_domain_name != null ? 1 : 0
  
  zone_id = local.zone_id
  name    = var.subdomain != "" ? "${var.subdomain}.${var.domain_name}" : var.domain_name
  type    = "A"

  alias {
    name                   = var.cloudfront_domain_name
    zone_id                = var.cloudfront_hosted_zone_id
    evaluate_target_health = false
  }
}

# 3. CREAR REGISTRO PARA WWW (opcional)
resource "aws_route53_record" "www" {
  count = var.cloudfront_domain_name != null && var.create_www_record ? 1 : 0
  
  zone_id = local.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.cloudfront_domain_name
    zone_id                = var.cloudfront_hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_query_log" "this" {
  count = var.create_hosted_zone ? 1 : 0
  
  zone_id                  = aws_route53_zone.this[0].zone_id
  cloudwatch_log_group_arn = aws_cloudwatch_log_group.this[0].arn  # ← agregar [0]
}

resource "aws_cloudwatch_log_group" "this" {
  count = var.create_hosted_zone ? 1 : 0
  
  name              = "/aws/route53/${var.domain_name}"
  retention_in_days = 30
}