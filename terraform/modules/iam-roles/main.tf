# ============================================
# MÓDULO: IAM Roles para Servicios y Usuarios
# ============================================

# 1. ROL PARA CODEPIPELINE (CI/CD)
resource "aws_iam_role" "codepipeline_role" {
  count = var.create_codepipeline_role ? 1 : 0
  
  name = "educloud-codepipeline-role-${var.environment}"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  
  tags = var.tags
}

# 2. POLÍTICA PARA CODEPIPELINE
resource "aws_iam_policy" "codepipeline_policy" {
  count = var.create_codepipeline_role ? 1 : 0
  
  name        = "educloud-codepipeline-policy-${var.environment}"
  description = "Política para CodePipeline de EduCloud"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:GetObjectVersion"
        ]
        Resource = [
          var.artifact_bucket_arn != null ? "${var.artifact_bucket_arn}/*" : "*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "codedeploy:CreateDeployment",
          "codedeploy:GetDeployment"
        ]
        Resource = "*"
      }
    ]
  })
}

# 3. ASOCIAR POLÍTICA AL ROL
resource "aws_iam_role_policy_attachment" "codepipeline_attach" {
  count = var.create_codepipeline_role ? 1 : 0
  
  role       = aws_iam_role.codepipeline_role[0].name
  policy_arn = aws_iam_policy.codepipeline_policy[0].arn
}

# ============================================
# 4. ROL PARA CODEBUILD (Compilación)
# ============================================
resource "aws_iam_role" "codebuild_role" {
  count = var.create_codebuild_role ? 1 : 0
  
  name = "educloud-codebuild-role-${var.environment}"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  
  tags = var.tags
}

# 5. POLÍTICA PARA CODEBUILD
resource "aws_iam_policy" "codebuild_policy" {
  count = var.create_codebuild_role ? 1 : 0
  
  name        = "educloud-codebuild-policy-${var.environment}"
  description = "Política para CodeBuild de EduCloud"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:GetObjectVersion"
        ]
        Resource = [
          var.artifact_bucket_arn != null ? "${var.artifact_bucket_arn}/*" : "*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      }
    ]
  })
}

# 6. ASOCIAR POLÍTICA AL ROL DE CODEBUILD
resource "aws_iam_role_policy_attachment" "codebuild_attach" {
  count = var.create_codebuild_role ? 1 : 0
  
  role       = aws_iam_role.codebuild_role[0].name
  policy_arn = aws_iam_policy.codebuild_policy[0].arn
}

# ============================================
# 7. ROL PARA TERRAFORM (Infraestructura)
# ============================================
resource "aws_iam_role" "terraform_role" {
  count = var.create_terraform_role ? 1 : 0
  
  name = "educloud-terraform-role-${var.environment}"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = var.terraform_user_arns
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  
  tags = var.tags
}

# 8. POLÍTICA PARA TERRAFORM (Administración completa)
resource "aws_iam_policy" "terraform_policy" {
  count = var.create_terraform_role ? 1 : 0
  
  name        = "educloud-terraform-policy-${var.environment}"
  description = "Política para Terraform de EduCloud"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:*",
          "s3:*",
          "cloudfront:*",
          "route53:*",
          "cognito-idp:*",
          "wafv2:*",
          "iam:*",
          "lambda:*",
          "apigateway:*",
          "cloudwatch:*",
          "logs:*",
          "dynamodb:*",
          "rds:*",
          "elasticache:*"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = "*"
        Condition = {
          "StringEquals" = {
            "iam:PassedToService" = [
              "ec2.amazonaws.com",
              "lambda.amazonaws.com",
              "rds.amazonaws.com"
            ]
          }
        }
      }
    ]
  })
}

# 9. ASOCIAR POLÍTICA AL ROL DE TERRAFORM
resource "aws_iam_role_policy_attachment" "terraform_attach" {
  count = var.create_terraform_role ? 1 : 0
  
  role       = aws_iam_role.terraform_role[0].name
  policy_arn = aws_iam_policy.terraform_policy[0].arn
}

# ============================================
# 10. ROL PARA USUARIOS AUTENTICADOS (API Access)
# ============================================
resource "aws_iam_role" "api_user_role" {
  count = var.create_api_user_role ? 1 : 0
  
  name = "educloud-api-user-role-${var.environment}"
  
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
            "cognito-identity.amazonaws.com:aud" = var.cognito_identity_pool_id != "" ? var.cognito_identity_pool_id : "FIXME"
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

# 11. POLÍTICA PARA USUARIOS API
resource "aws_iam_policy" "api_user_policy" {
  count = var.create_api_user_role ? 1 : 0
  
  name        = "educloud-api-user-policy-${var.environment}"
  description = "Política para usuarios autenticados de API"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "execute-api:Invoke"
        ]
        Resource = "${var.api_gateway_arn != "" ? var.api_gateway_arn : "*"}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = var.s3_bucket_arn != "" ? "${var.s3_bucket_arn}/*" : "*"
        Condition = {
          "StringEquals" = {
            "s3:prefix" = "uploads/${var.cognito_username_key}/*"
          }
        }
      }
    ]
  })
}

# 12. ASOCIAR POLÍTICA AL ROL DE USUARIO
resource "aws_iam_role_policy_attachment" "api_user_attach" {
  count = var.create_api_user_role ? 1 : 0
  
  role       = aws_iam_role.api_user_role[0].name
  policy_arn = aws_iam_policy.api_user_policy[0].arn
}
