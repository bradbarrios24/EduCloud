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

# 6. MODULO: IAM Roles (Para servicios)
module "iam_roles" {
  source = "../../modules/iam-roles"
  
  environment = var.environment
  
  # Roles para CI/CD (opcional por ahora)
  create_codepipeline_role = false  # Lo activaremos después
  create_codebuild_role    = false  # Lo activaremos después
  create_terraform_role    = false  # Lo activaremos después
  
  # Para usuarios autenticados (opcional)
  create_api_user_role       = var.create_api_user_roles
  cognito_identity_pool_id   = module.cognito.identity_pool_id
  s3_bucket_arn              = module.s3_frontend.bucket_arn
  
  tags = local.common_tags
}

# ============================================
# NOTA: Los OUTPUTS están en outputs.tf
# ============================================