# ============================================
# MÓDULO: WAF (Web Application Firewall)
# ============================================

# 1. OBTENER REGLAS MANAGED DE AWS
data "aws_wafv2_rule_group" "aws_managed_rules" {
  name   = "AWSManagedRulesCommonRuleSet"
  scope  = "CLOUDFRONT"
}

data "aws_wafv2_rule_group" "aws_managed_sql" {
  name   = "AWSManagedRulesSQLiRuleSet"
  scope  = "CLOUDFRONT"
}

# 2. CREAR ACL (Access Control List)
resource "aws_wafv2_web_acl" "this" {
  name        = var.waf_name
  description = var.waf_description
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  # REGLA 1: Reglas Managed de AWS
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = data.aws_wafv2_rule_group.aws_managed_rules.name
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  # REGLA 2: Protección SQL Injection
  rule {
    name     = "AWSManagedRulesSQLiRuleSet"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = data.aws_wafv2_rule_group.aws_managed_sql.name
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesSQLiRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  # REGLA 3: Rate Limiting (evitar ataques DDoS)
  rule {
    name     = "RateLimitRule"
    priority = 3

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = var.rate_limit
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitRuleMetric"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.waf_name}Metric"
    sampled_requests_enabled   = true
  }

  tags = var.tags
}

# 3. ASOCIAR WAF CON CLOUDFRONT
resource "aws_wafv2_web_acl_association" "this" {
  count = var.cloudfront_distribution_arn != null ? 1 : 0
  
  resource_arn = var.cloudfront_distribution_arn
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}