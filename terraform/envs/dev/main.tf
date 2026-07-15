# ============================================
# CONFIGURACIÓN PRINCIPAL - EduCloud DEV
# ============================================

# 1. MODULO: S3 para Frontend
module "s3_frontend" {
  source = "../../modules/s3-frontend"

  bucket_name                 = var.bucket_name != "" ? var.bucket_name : null
  cloudfront_distribution_arn = module.cloudfront.cloudfront_arn

  tags = merge(local.common_tags, {
    Name = "EduCloud-Frontend-${var.environment}"
  })
}

# 2. MODULO: CloudFront CDN
module "cloudfront" {
  source = "../../modules/cloudfront"

  s3_bucket_domain_name = module.s3_frontend.bucket_regional_domain_name
  origin_id = "S3FrontendOrigin"

  # Configuración personalizada para dev
  default_ttl = 300  # Menos caché en dev
  web_acl_id = module.waf.waf_arn

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

  associate_with_cloudfront   = true                              # ← bool estático
  cloudfront_distribution_arn = module.cloudfront.cloudfront_arn # ← ARN sigue aquí

  tags = local.common_tags
}

# 4. MODULO: Route53 (DNS) - Solo si tienes dominio
module "route53" {
  count = 0

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

  create_codepipeline_role = false
  create_codebuild_role    = false
  create_terraform_role    = false

  create_api_user_role       = var.create_api_user_roles
  cognito_identity_pool_id   = module.cognito.identity_pool_id
  s3_bucket_arn              = module.s3_frontend.bucket_arn

  api_gateway_execution_arn = module.api_gateway.execution_arn
  uploads_bucket_arn = module.s3_uploads.bucket_arn

  tags = local.common_tags
}

# 7. MÓDULO: API Gateway
module "api_gateway" {
  source = "../../modules/api-gateway"

  api_name              = "educloud-api-${var.environment}"
  api_description       = "API REST de EduCloud - ${var.environment}"
  stage_name            = var.environment
  cognito_user_pool_arn = module.cognito.user_pool_arn

  sqs_queue_arn = module.sqs.queue_arn

  tags = local.common_tags
}

# 8. SNS (fuera de modules/, independiente y reutilizable)
module "sns" {
  source = "../../sns"

  topic_name  = "educloud-alerts-${var.environment}"
  alarm_email = var.alarm_email

  tags = local.common_tags
}

# 9. MÓDULO: CloudWatch (Alarmas + Logs Insights + Dashboard + X-Ray)
module "cloudwatch" {
  source = "../../modules/cloudwatch"

  environment    = var.environment
  aws_region     = var.aws_region
  dashboard_name = "EduCloud-Monitoring"

  sns_topic_arn = module.sns.topic_arn

  s3_bucket_name             = module.s3_frontend.bucket_name
  cloudfront_distribution_id = module.cloudfront.cloudfront_distribution_id
  api_gateway_name           = "educloud-api-${var.environment}"
  api_gateway_stage          = var.environment

  tags = local.common_tags
}

# ============================================
# NUEVO: Pipeline de mensajería asíncrona
# API Gateway -> SQS -> Lambda -> SES
# ============================================

# 10. MODULO: VPC (Red privada para la Lambda procesadora)
module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  availability_zone   = var.availability_zone

  environment = var.environment
  tags        = local.common_tags
}

# 11. MODULO: SQS (Cola de mensajes + Dead Letter Queue)
module "sqs" {
  source = "../../modules/sqs"

  queue_name = var.sqs_queue_name
  dlq_name   = var.sqs_dlq_name

  # Tras N=5 reintentos, el mensaje se mueve a la DLQ.
  max_receive_count = var.sqs_max_receive_count

  message_retention_seconds  = var.sqs_message_retention_seconds
  visibility_timeout_seconds = var.sqs_visibility_timeout_seconds

  environment = var.environment
  tags        = local.common_tags
}

# 12. MODULO: SES (Envío de emails)
module "ses" {
  source = "../../modules/ses"

  domain = var.ses_domain != "" ? var.ses_domain : null
  email  = var.ses_email != "" ? var.ses_email : null

  enable_configuration_set = var.ses_enable_configuration_set

  environment = var.environment
  tags        = local.common_tags
}

# 13. LAMBDA: lambda_processor
# Ubicada FUERA de modules/, en la raíz de terraform/, para poder agregar
# más lambdas como carpetas hermanas en el futuro.
module "lambda_processor" {
  source = "../../lambda_processor"

  function_name = var.lambda_processor_function_name
  runtime       = var.lambda_processor_runtime
  handler       = var.lambda_processor_handler
  memory_size   = var.lambda_processor_memory_size
  timeout       = var.lambda_processor_timeout
  batch_size    = var.lambda_processor_batch_size

  lambda_zip_path = var.lambda_processor_zip_path

  sqs_queue_arn      = module.sqs.queue_arn
  private_subnet_id  = module.vpc.private_subnet_id
  security_group_id  = module.vpc.lambda_security_group_id

  environment_variables = merge(
    var.lambda_processor_environment_variables,
    {
      SES_SENDER = var.ses_email != "" ? var.ses_email : var.ses_domain
    }
  )

  environment = var.environment
  tags        = local.common_tags
}

# 14. MODULO: VPC Endpoints (opcional - SES sin salir por el NAT Gateway)
module "vpc_endpoints" {
  count  = var.enable_vpc_endpoints ? 1 : 0
  source = "../../modules/vpc_endpoints"

  vpc_id             = module.vpc.vpc_id
  private_subnet_id  = module.vpc.private_subnet_id
  security_group_id  = module.vpc.lambda_security_group_id
  region             = var.aws_region

  environment = var.environment
  tags        = local.common_tags
}

# 15. MÓDULO: S3 Uploads
module "s3_uploads" {
  source = "../../modules/s3-uploads"

  bucket_prefix = "educloud-uploads"
  environment   = var.environment

  cors_allowed_origins = ["https://${module.cloudfront.cloudfront_domain_name}"]

  tags = local.common_tags
}

# En envs/dev/main.tf

module "ecs_cluster" {
  source = "../../modules/ecs-cluster"

  cluster_name = "demo-tools-${var.environment}"
  use_spot     = true # más barato para una demo de 8h

  tags = local.common_tags
}

module "ecs_grafana" {
  source = "../../modules/ecs-grafana"

  environment         = var.environment
  vpc_id              = module.vpc.vpc_id           # ajusta al output real de tu módulo vpc
  subnet_id            = module.vpc.public_subnet_id # ajusta al output real
  cluster_id           = module.ecs_cluster.cluster_id
  execution_role_arn   = module.ecs_cluster.execution_role_arn
  allowed_cidr_blocks  = ["190.235.110.178/32"] # reemplaza por tu IP real
  admin_password       = var.grafana_admin_password

  tags = local.common_tags
}

module "ecs_sonarqube" {
  source = "../../modules/ecs-sonarqube"

  environment         = var.environment
  vpc_id              = module.vpc.vpc_id
  subnet_id            = module.vpc.public_subnet_id
  cluster_id           = module.ecs_cluster.cluster_id
  execution_role_arn   = module.ecs_cluster.execution_role_arn
  allowed_cidr_blocks = ["0.0.0.0/0"]
  db_password          = var.sonarqube_db_password

  tags = local.common_tags
}

module "ecs_jenkins" {
  source = "../../modules/ecs-jenkins"

  environment         = var.environment
  vpc_id              = module.vpc.vpc_id           # ajusta al output real de tu módulo vpc
  subnet_id           = module.vpc.public_subnet_id # ajusta al output real
  cluster_id          = module.ecs_cluster.cluster_id
  execution_role_arn  = module.ecs_cluster.execution_role_arn
  allowed_cidr_blocks = ["190.235.110.178/32"] # reemplaza por tu IP real
  aws_region          = var.aws_region

  tags = local.common_tags
}

# ============================================
# NOTA: Los OUTPUTS están en outputs.tf
# ============================================