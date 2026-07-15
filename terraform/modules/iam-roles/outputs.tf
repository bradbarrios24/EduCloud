# ============================================
# OUTPUTS DEL MÓDULO IAM ROLES
# ============================================

# Outputs de CodePipeline
output "codepipeline_role_arn" {
  description = "ARN del rol de CodePipeline"
  value       = try(aws_iam_role.codepipeline_role[0].arn, null)
}

output "codepipeline_role_name" {
  description = "Nombre del rol de CodePipeline"
  value       = try(aws_iam_role.codepipeline_role[0].name, null)
}

# Outputs de CodeBuild
output "codebuild_role_arn" {
  description = "ARN del rol de CodeBuild"
  value       = try(aws_iam_role.codebuild_role[0].arn, null)
}

output "codebuild_role_name" {
  description = "Nombre del rol de CodeBuild"
  value       = try(aws_iam_role.codebuild_role[0].name, null)
}

# Outputs de Terraform
output "terraform_role_arn" {
  description = "ARN del rol de Terraform"
  value       = try(aws_iam_role.terraform_role[0].arn, null)
}

output "terraform_role_name" {
  description = "Nombre del rol de Terraform"
  value       = try(aws_iam_role.terraform_role[0].name, null)
}

# Outputs de API Users
output "api_user_role_arn" {
  description = "ARN del rol de API Users"
  value       = try(aws_iam_role.api_user_role[0].arn, null)
}

output "api_user_role_name" {
  description = "Nombre del rol de API Users"
  value       = try(aws_iam_role.api_user_role[0].name, null)
}

output "admin_role_arn" {
  value = var.create_role_based_access ? aws_iam_role.admin_role[0].arn : null
}

output "docente_role_arn" {
  value = var.create_role_based_access ? aws_iam_role.docente_role[0].arn : null
}

output "estudiante_role_arn" {
  value = var.create_role_based_access ? aws_iam_role.estudiante_role[0].arn : null
}