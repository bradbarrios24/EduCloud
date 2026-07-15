output "identity_arn" {
  description = "ARN de la identidad SES verificada (dominio o email)"
  value       = var.domain != null ? aws_ses_domain_identity.this[0].arn : aws_ses_email_identity.this[0].arn
}

output "verified_identity" {
  description = "Nombre del dominio o email verificado"
  value       = var.domain != null ? aws_ses_domain_identity.this[0].domain : aws_ses_email_identity.this[0].email
}

output "domain_verification_token" {
  description = "Token TXT de verificacion de dominio (registro DNS _amazonses.<dominio>). Null si se usa verificacion por email."
  value       = var.domain != null ? aws_ses_domain_identity.this[0].verification_token : null
}

output "dkim_tokens" {
  description = "Tokens DKIM a agregar como registros CNAME <token>._domainkey.<dominio>. Null si se usa verificacion por email."
  value       = var.domain != null ? aws_ses_domain_dkim.this[0].dkim_tokens : null
}

output "configuration_set_name" {
  description = "Nombre del Configuration Set de SES (si aplica)"
  value       = var.enable_configuration_set ? aws_ses_configuration_set.this[0].name : null
}