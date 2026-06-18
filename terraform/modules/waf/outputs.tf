# ============================================
# OUTPUTS DEL MÓDULO WAF
# ============================================

output "waf_arn" {
  description = "ARN del WAF"
  value       = aws_wafv2_web_acl.this.arn
}

output "waf_id" {
  description = "ID del WAF"
  value       = aws_wafv2_web_acl.this.id
}

output "waf_name" {
  description = "Nombre del WAF"
  value       = aws_wafv2_web_acl.this.name
}