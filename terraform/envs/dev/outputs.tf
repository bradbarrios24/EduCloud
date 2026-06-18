# ============================================
# OUTPUTS DEL ENTORNO DEV - EduCloud
# ============================================

# ============================================
# 1. OUTPUTS DE S3
# ============================================

output "s3_bucket_name" {
  description = "Nombre del bucket S3 para el frontend"
  value       = module.s3_frontend.bucket_name
}

output "s3_bucket_arn" {
  description = "ARN del bucket S3"
  value       = module.s3_frontend.bucket_arn
}

output "s3_bucket_domain" {
  description = "Dominio del bucket S3"
  value       = module.s3_frontend.bucket_domain_name
}

# ============================================
# 2. OUTPUTS DE CLOUDFRONT
# ============================================

output "cloudfront_domain" {
  description = "Dominio de CloudFront (CDN)"
  value       = module.cloudfront.cloudfront_domain_name
}

output "cloudfront_distribution_id" {
  description = "ID de la distribución CloudFront"
  value       = module.cloudfront.cloudfront_distribution_id
}

output "cloudfront_url" {
  description = "URL completa de CloudFront"
  value       = "https://${module.cloudfront.cloudfront_domain_name}"
}

# ============================================
# 3. OUTPUTS DE WAF
# ============================================

output "waf_arn" {
  description = "ARN del WAF (Web Application Firewall)"
  value       = module.waf.waf_arn
}

output "waf_name" {
  description = "Nombre del WAF"
  value       = module.waf.waf_name
}

# ============================================
# 4. OUTPUTS DE ROUTE53 (DNS)
# ============================================

output "route53_zone_id" {
  description = "ID del Hosted Zone en Route53"
  value       = try(module.route53[0].zone_id, null)
}

output "website_domain" {
  description = "Dominio personalizado del sitio web"
  value       = try(module.route53[0].full_domain, null)
}

# ============================================
# 5. OUTPUTS DE COGNITO
# ============================================

output "cognito_user_pool_id" {
  description = "ID del User Pool de Cognito"
  value       = module.cognito.user_pool_id
}

output "cognito_user_pool_arn" {
  description = "ARN del User Pool de Cognito"
  value       = module.cognito.user_pool_arn
}

output "cognito_client_id" {
  description = "ID del cliente de Cognito (para el frontend)"
  value       = module.cognito.client_id
}

output "cognito_client_secret" {
  description = "Secret del cliente de Cognito"
  value       = module.cognito.client_secret
  sensitive   = true  # ⚠️ No mostrar en logs
}

output "cognito_login_url" {
  description = "URL de login de Cognito"
  value       = module.cognito.login_url
}

output "cognito_domain" {
  description = "Dominio de autenticación de Cognito"
  value       = module.cognito.domain
}

# ============================================
# 6. OUTPUTS DE IAM ROLES
# ============================================

output "codepipeline_role_arn" {
  description = "ARN del rol de CodePipeline"
  value       = module.iam_roles.codepipeline_role_arn
}

output "codebuild_role_arn" {
  description = "ARN del rol de CodeBuild"
  value       = module.iam_roles.codebuild_role_arn
}

output "terraform_role_arn" {
  description = "ARN del rol de Terraform"
  value       = module.iam_roles.terraform_role_arn
}

output "api_user_role_arn" {
  description = "ARN del rol para usuarios autenticados de API"
  value       = module.iam_roles.api_user_role_arn
}

# ============================================
# 7. OUTPUTS COMBINADOS (UTILIDAD)
# ============================================

output "website_url" {
  description = "URL principal del sitio web"
  value = var.domain_name != "" ? (
    "https://${var.subdomain}.${var.domain_name}"
  ) : (
    "https://${module.cloudfront.cloudfront_domain_name}"
  )
}

output "cdn_url" {
  description = "URL de CloudFront"
  value       = "https://${module.cloudfront.cloudfront_domain_name}"
}

output "full_infrastructure_summary" {
  description = "Resumen completo de la infraestructura"
  value = {
    # Frontend
    s3_bucket          = module.s3_frontend.bucket_name
    cloudfront_url     = "https://${module.cloudfront.cloudfront_domain_name}"
    website_url        = var.domain_name != "" ? "https://${var.subdomain}.${var.domain_name}" : null
    
    # Seguridad
    waf_enabled        = true
    waf_arn            = module.waf.waf_arn
    
    # Autenticación
    cognito_user_pool  = module.cognito.user_pool_id
    cognito_login_url  = module.cognito.login_url
    
    # DNS
    dns_zone_id        = try(module.route53[0].zone_id, null)
    custom_domain      = var.domain_name != "" ? var.domain_name : null
  }
}

# ============================================
# 8. OUTPUTS PARA CI/CD (Útiles para pipelines)
# ============================================

output "ci_cd_config" {
  description = "Configuración para pipelines de CI/CD"
  value = {
    s3_bucket            = module.s3_frontend.bucket_name
    cloudfront_id        = module.cloudfront.cloudfront_distribution_id
    cognito_user_pool_id = module.cognito.user_pool_id
    cognito_client_id    = module.cognito.client_id
  }
}