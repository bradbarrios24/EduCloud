# ============================================
# CONFIGURACIÓN PRINCIPAL - EduCloud DEV
# ============================================

# 1. MODULO: S3 para Frontend
module "s3_frontend" {
  source = "../../modules/s3-frontend"
  
  bucket_name = var.bucket_name != "" ? var.bucket_name : null
  
  tags = merge(local.common_tags, {
    Name = "EduCloud-Frontend-${var.environment}"
  })
}

# 2. MODULO: CloudFront CDN
module "cloudfront" {
  source = "../../modules/cloudfront"
  
  s3_bucket_domain_name = module.s3_frontend.bucket_domain_name
  s3_bucket_arn         = module.s3_frontend.bucket_arn
  s3_bucket_id          = module.s3_frontend.bucket_id
  
  origin_id = "S3FrontendOrigin"
  
  # Configuración personalizada para dev
  default_ttl = 300  # Menos caché en dev
  
  tags = merge(local.common_tags, {
    Name = "EduCloud-CDN-${var.environment}"
  })
}

# 3. MODULO: WAF (Firewall)
module "waf" {
  source = "../../modules/waf"
  
  waf_name        = "educloud-waf-${var.environment}"
  waf_description = "WAF para proteger CloudFront en ${var.environment}"
  rate_limit      = var.waf_rate_limit
  
  cloudfront_distribution_arn = module.cloudfront.cloudfront_arn
  
  tags = local.common_tags
}

# 4. MODULO: Route53 (DNS) - Solo si tienes dominio
module "route53" {
  count = var.domain_name != "" ? 1 : 0
  
  source = "../../modules/route53"
  
  domain_name              = var.domain_name
  subdomain                = var.subdomain
  create_hosted_zone       = var.create_hosted_zone
  create_www_record        = var.create_www_record
  
  cloudfront_domain_name   = module.cloudfront.cloudfront_domain_name
  cloudfront_hosted_zone_id = module.cloudfront.cloudfront_hosted_zone_id
  
  tags = local.common_tags
}

# 5. MODULO: Cognito (Autenticación)
module "cognito" {
  source = "../../modules/cognito"
  
  user_pool_name = "educloud-users-${var.environment}"
  client_name    = "educloud-webapp-${var.environment}"
  
  callback_urls  = var.cognito_callback_urls
  logout_urls    = var.cognito_logout_urls
  default_redirect_uri = var.cognito_default_redirect_uri
  
  create_domain      = true
  domain_prefix      = var.cognito_domain_prefix != "" ? var.cognito_domain_prefix : "auth-${var.environment}"
  create_admin_group = true
  
  # Opcional: Identity Pool para acceso directo a S3
  create_identity_pool = var.create_identity_pool
  s3_bucket_arn        = module.s3_frontend.bucket_arn
  
  tags = local.common_tags
}

# ============================================
# OUTPUTS DEL ENTORNO DEV
# ============================================

# Outputs de S3
output "s3_bucket_name" {
  description = "Nombre del bucket S3"
  value       = module.s3_frontend.bucket_name
}

output "s3_bucket_arn" {
  description = "ARN del bucket S3"
  value       = module.s3_frontend.bucket_arn
}

# Outputs de CloudFront
output "cloudfront_domain" {
  description = "Dominio de CloudFront"
  value       = module.cloudfront.cloudfront_domain_name
}

output "cloudfront_distribution_id" {
  description = "ID de la distribución CloudFront"
  value       = module.cloudfront.cloudfront_distribution_id
}

# Outputs de WAF
output "waf_arn" {
  description = "ARN del WAF"
  value       = module.waf.waf_arn
}

# Outputs de Route53 (si existe)
output "route53_zone_id" {
  description = "ID del Hosted Zone"
  value       = try(module.route53[0].zone_id, null)
}

output "website_domain" {
  description = "Dominio del sitio web"
  value       = try(module.route53[0].full_domain, null)
}

# Outputs de Cognito
output "cognito_user_pool_id" {
  description = "ID del User Pool de Cognito"
  value       = module.cognito.user_pool_id
}

output "cognito_client_id" {
  description = "ID del cliente de Cognito"
  value       = module.cognito.client_id
}

output "cognito_login_url" {
  description = "URL de login de Cognito"
  value       = module.cognito.login_url
}

# Output combinado - ✅ CORREGIDO
output "website_url" {
  description = "URL del sitio web"
  value = var.domain_name != "" ? (
    "https://${var.subdomain}.${var.domain_name}"
  ) : (
    "https://${module.cloudfront.cloudfront_domain_name}"
  )
}

# Outputs adicionales útiles
output "cdn_url" {
  description = "URL de CloudFront"
  value       = "https://${module.cloudfront.cloudfront_domain_name}"
}

output "full_infrastructure" {
  description = "Resumen de la infraestructura"
  value = {
    s3_bucket          = module.s3_frontend.bucket_name
    cloudfront_url     = "https://${module.cloudfront.cloudfront_domain_name}"
    website_url        = var.domain_name != "" ? "https://${var.subdomain}.${var.domain_name}" : null
    cognito_login_url  = module.cognito.login_url
    waf_enabled        = true
  }
}