# ============================================
# MÓDULO: Cognito (Autenticación)
# ============================================

# 1. USER POOL (Base de datos de usuarios)
resource "aws_cognito_user_pool" "this" {
  name = var.user_pool_name
  
  # Política de contraseñas
  password_policy {
    minimum_length                   = var.minimum_password_length
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }
  
  # Configuración de cuenta
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }
  
  # Auto-verificación de email
  auto_verified_attributes = ["email"]
  
  tags = var.tags
}

# 2. USER POOL CLIENT (Frontend app)
resource "aws_cognito_user_pool_client" "this" {
  name = var.client_name
  
  user_pool_id = aws_cognito_user_pool.this.id
  
  # Configuración OAuth
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["implicit", "code"]
  allowed_oauth_scopes                 = ["email", "openid", "profile"]
  
  # Callbacks y logout
  callback_urls        = var.callback_urls
  logout_urls          = var.logout_urls
  default_redirect_uri = var.default_redirect_uri
  
  # Soporte para web
  supported_identity_providers = ["COGNITO"]
  
  # Generar secret para el cliente
  generate_secret = var.generate_client_secret
  
  # Acceso a los atributos
  read_attributes  = ["email", "name", "picture"]
  write_attributes = ["email", "name"]
  
  # Sesión
  refresh_token_validity = 30
  access_token_validity  = 1
  id_token_validity      = 1
  
  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }
}

# 3. USER POOL DOMAIN (URL de login)
resource "aws_cognito_user_pool_domain" "this" {
  count = var.create_domain ? 1 : 0
  
  domain       = var.domain_prefix != "" ? var.domain_prefix : "auth-${random_id.suffix[0].hex}"
  user_pool_id = aws_cognito_user_pool.this.id
}

resource "random_id" "suffix" {
  count       = var.domain_prefix == "" ? 1 : 0
  byte_length = 4
}

# 4. USER GROUP (Administradores)
resource "aws_cognito_user_group" "admins" {
  count = var.create_admin_group ? 1 : 0
  
  name         = "Admins"
  user_pool_id = aws_cognito_user_pool.this.id
  description  = "Grupo de administradores de EduCloud"
}

# 5. IDENTITY POOL (Para acceso a AWS desde frontend)
resource "aws_cognito_identity_pool" "this" {
  count = var.create_identity_pool ? 1 : 0
  
  identity_pool_name               = "${var.user_pool_name}-identity-pool"
  allow_unauthenticated_identities = false
  
  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.this.id
    provider_name           = "cognito-idp.${data.aws_region.current.name}.amazonaws.com/${aws_cognito_user_pool.this.id}"
    server_side_token_check = true
  }
}

# 6. ROL IAM PARA IDENTITY POOL
resource "aws_iam_role" "authenticated" {
  count = var.create_identity_pool ? 1 : 0
  
  name = "${var.user_pool_name}-authenticated-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "cognito-identity.amazonaws.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          "StringEquals" = {
            "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.this[0].id
          }
          "ForAnyValue:StringLike" = {
            "cognito-identity.amazonaws.com:amr" = "authenticated"
          }
        }
      }
    ]
  })
  
  tags = var.tags
}

resource "aws_iam_role_policy" "authenticated" {
  count = var.create_identity_pool ? 1 : 0
  
  name = "${var.user_pool_name}-authenticated-policy"
  role = aws_iam_role.authenticated[0].id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = var.s3_bucket_arn != null ? "${var.s3_bucket_arn}/*" : "*"
      }
    ]
  })
}

# 7. OUTPUTS INTERNOS
data "aws_region" "current" {}
